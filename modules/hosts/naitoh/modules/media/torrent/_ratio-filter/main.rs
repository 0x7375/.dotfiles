use serde::Deserialize;
use std::{
    env, fmt,
    process::exit,
    time::{SystemTime, UNIX_EPOCH},
};

const GRACE_PERIOD_DAYS: u64 = 7;
const GRACE_PERIOD_SECONDS: u64 = GRACE_PERIOD_DAYS * 60 * 60 * 24;
const DAY_IN_SEC: u64 = 60 * 60 * 24;
const TARGET_CATEGORY: &str = "autobrr";
const TOTAL_CAPACITY_BYTES: u64 = 150 * 1024 * 1024 * 1024;
const MINIMUM_SCORE_THRESHOLD: f32 = 0.75;

#[derive(Deserialize, Debug)]
struct Torrent {
    hash: String,
    name: String,
    seeding_time: u64,
    last_activity: u64,
    ratio: f32,
    size: f32,
}

fn elapsed(time: u64) -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs()
        .saturating_sub(time)
}

impl fmt::Display for Torrent {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "[{name}...]\tSize: {size:.2}GB\t| Ratio: {ratio:.2}\t| Days: {days:.1}\t| Score: {score:.2}",
            name = self.name.chars().take(40).collect::<String>(),
            size = self.size / (1024 * 1024 * 1024) as f32,
            ratio = self.ratio,
            days = self.seeding_time as f32 / DAY_IN_SEC as f32,
            score = self.score()
        )
    }
}

impl Torrent {
    fn score(&self) -> f32 {
        let days_seeded = (self.seeding_time as f32 / DAY_IN_SEC as f32).max(1.0);
        let days_inactive = elapsed(self.last_activity) / DAY_IN_SEC;
        let decay = 0.5_f32.powf(days_inactive as f32 / 3.0);

        (self.ratio / days_seeded) * decay
    }
}

fn main() {
    let mut args = env::args();
    args.next();
    let (Some(url), Some(pw), dry, None) = (args.next(), args.next(), args.next(), args.next())
    else {
        eprintln!("Usage: <url> <password> [--dry]");
        exit(1);
    };

    let agent = ureq::agent();

    let response = agent
        .post(format!("{}/api/v2/auth/login", &url))
        .header("Referer", &url)
        .send_form([("username", "admin"), ("password", &pw)]);

    match response {
        Ok(r) => {
            if !r.headers().contains_key("set-cookie") {
                eprintln!("Login failed, did not get an auth cookie");
                exit(1);
            }
        }
        Err(e) => {
            eprintln!("Login failed: {e}");
            exit(1);
        }
    };

    let mut torrents = agent
        .get(format!(
            "{}/api/v2/torrents/info?category={TARGET_CATEGORY}",
            &url
        ))
        .call()
        .unwrap()
        .body_mut()
        .read_json::<Vec<Torrent>>()
        .unwrap();

    torrents.sort_by(|a, b| {
        let score_a = if a.seeding_time < GRACE_PERIOD_SECONDS {
            f32::MAX
        } else {
            a.score()
        };
        let score_b = if b.seeding_time < GRACE_PERIOD_SECONDS {
            f32::MAX
        } else {
            b.score()
        };
        score_a.total_cmp(&score_b).reverse()
    });

    let mut capacity = 0.0;
    let mut to_delete: Vec<Torrent> = vec![];

    println!("--- KEEPING ---");
    for torrent in torrents {
        if torrent.seeding_time < GRACE_PERIOD_SECONDS {
            capacity += torrent.size;
            println!("(GRACE)\t{}", torrent);
            continue;
        }

        if torrent.score() < MINIMUM_SCORE_THRESHOLD
            || capacity + torrent.size > TOTAL_CAPACITY_BYTES as f32
        {
            to_delete.push(torrent);
        } else {
            capacity += torrent.size;
            println!("(GOOD)\t{}", torrent);
        }
    }

    if to_delete.is_empty() {
        println!("Nothing to delete");
        exit(0)
    }

    println!("--- DELETING ---");
    for torrent in &to_delete {
        println!("{}", torrent);
    }

    if dry != Some("--dry".to_string()) {
        let hashes: Vec<String> = to_delete.iter().map(|t| t.hash.clone()).collect();
        let response = agent
            .post(format!("{}/api/v2/torrents/delete", &url))
            .header("Referer", &url)
            .send_form([
                ("hashes", hashes.join("|")),
                ("deleteFiles", "true".to_string()),
            ]);

        if let Err(e) = response {
            eprintln!("Failed to delete torrents: {e}");
            exit(1)
        }
    }

    println!("Deleted {} torrents.", to_delete.len());
}
