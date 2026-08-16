use serde::{Deserialize, Serialize};
use std::{
    collections::HashMap,
    env, fmt, fs,
    process::exit,
    time::{SystemTime, UNIX_EPOCH},
};
use ureq::Agent;

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
    added_on: u64,
    last_activity: u64,
    ratio: f32,
    size: f32,
    uploaded: u64,
    downloaded: u64,
    tracker: String,
}

#[derive(Serialize, Deserialize, Default)]
struct Stats {
    week: u64,
    trackers: HashMap<String, i64>,
    torrents: HashMap<String, i64>,
}

fn elapsed(time: u64) -> u64 {
    SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs()
        .saturating_sub(time)
}

fn get_sunday_midnight() -> u64 {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .unwrap()
        .as_secs();
    let days = now / DAY_IN_SEC;
    now - (((days + 4) % 7) * DAY_IN_SEC) - (now % DAY_IN_SEC)
}

impl fmt::Display for Torrent {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(
            f,
            "[{name}...]\tSize: {size:.2} GB\t| Ratio: {ratio:.2}\t| Days: {days:.1}\t| Score: {score:.2}",
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

struct ConnectionInfo {
    agent: Agent,
    url: String,
}

fn login(conn: &ConnectionInfo, pw: &str) {
    match conn
        .agent
        .post(format!("{}/api/v2/auth/login", conn.url))
        .header("Referer", &conn.url)
        .send_form([("username", "admin"), ("password", pw)])
    {
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
    }
}

fn get_torrents(conn: &ConnectionInfo) -> Vec<Torrent> {
    conn.agent
        .get(format!(
            "{}/api/v2/torrents/info?category={TARGET_CATEGORY}",
            &conn.url
        ))
        .call()
        .unwrap()
        .body_mut()
        .read_json::<Vec<Torrent>>()
        .unwrap()
}

fn delete_torrents(conn: &ConnectionInfo, to_delete: &[Torrent]) {
    let hashes: Vec<String> = to_delete.iter().map(|t| t.hash.clone()).collect();
    let response = conn
        .agent
        .post(format!("{}/api/v2/torrents/delete", conn.url))
        .header("Referer", &conn.url)
        .send_form([
            ("hashes", hashes.join("|")),
            ("deleteFiles", "true".to_string()),
        ]);

    if let Err(e) = response {
        eprintln!("Failed to delete torrents: {e}");
        exit(1)
    }
}

fn track_weekly_stats(torrents: &[Torrent], is_dry: bool) {
    let current_sunday = get_sunday_midnight();

    let mut stats: Stats = fs::read_to_string("stats.json")
        .ok()
        .and_then(|s| serde_json::from_str(&s).ok())
        .unwrap_or_default();

    if stats.week != current_sunday {
        stats.week = current_sunday;
        stats.trackers.clear();
    }

    let mut current_torrents = HashMap::new();

    for t in torrents {
        let net = t.uploaded as i64 - t.downloaded as i64;
        let diff = match stats.torrents.get(&t.hash) {
            Some(&prev) => net - prev,
            None if t.added_on >= current_sunday => net,
            None => 0,
        };

        *stats.trackers.entry(t.tracker.clone()).or_default() += diff;
        current_torrents.insert(t.hash.clone(), net);
    }

    stats.torrents = current_torrents;

    for (tracker, net) in &stats.trackers {
        let tracker = tracker.split("/").nth(2).unwrap_or(tracker);

        println!("{tracker}:\t{:+.2} GB", *net as f64 / 1_073_741_824.0);
    }

    if let Ok(json) = serde_json::to_string(&stats)
        && !is_dry
    {
        let _ = fs::write("stats.json", json);
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
    let conn = ConnectionInfo { agent, url };

    login(&conn, &pw);

    let mut torrents = get_torrents(&conn);

    println!("--- WEEKLY SUMMARY ---");
    let is_dry = dry == Some("--dry".to_string());
    track_weekly_stats(&torrents, is_dry);

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

    if !is_dry {
        delete_torrents(&conn, &to_delete);
    }

    println!("Deleted {} torrents.", to_delete.len());
}
