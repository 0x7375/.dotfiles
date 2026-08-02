package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"math"
	"net/http"
	"net/url"
	"sort"
	"strings"
	"time"
)

const (
	QbitURL         = "http://localhost:8282"
	GlobalCapBytes  = 150 * 1024 * 1024 * 1024
	GracePeriodDays = 7.0
	Category        = "autobrr"
)

type Torrent struct {
	Hash         string  `json:"hash"`
	Name         string  `json:"name"`
	Size         int64   `json:"size"`
	Ratio        float64 `json:"ratio"`
	SeedingTime  int64   `json:"seeding_time"`
	LastActivity int64   `json:"last_activity"`
	AddedOn      int64   `json:"added_on"`
}

func getScore(t Torrent, now int64) float64 {
	daysSeeded := float64(t.SeedingTime) / 86400.0
	if daysSeeded < 0.001 {
		daysSeeded = 0.001
	}
	if daysSeeded < GracePeriodDays {
		return math.Inf(1)
	}

	globalYield := t.Ratio / daysSeeded

	lastAct := t.LastActivity
	if lastAct < 1000000 {
		lastAct = t.AddedOn
	}

	daysInactive := float64(now-lastAct) / 86400.0
	if daysInactive < 0 {
		daysInactive = 0
	}

	decay := math.Pow(0.5, daysInactive/3.0)
	return globalYield * decay
}

func main() {
	dryRun := flag.Bool("dry", false, "run in dry-run mode without deleting files")
	flag.Parse()

	resp, err := http.Get(QbitURL + "/api/v2/torrents/info?category=" + Category)
	if err != nil {
		fmt.Println("Error:", err)
		return
	}
	defer resp.Body.Close()

	var torrents []Torrent
	json.NewDecoder(resp.Body).Decode(&torrents)

	now := time.Now().Unix()

	sort.Slice(torrents, func(i, j int) bool {
		return getScore(torrents[i], now) > getScore(torrents[j], now)
	})

	var keptSize int64
	var toDelete []Torrent

	for _, t := range torrents {
		daysSeeded := float64(t.SeedingTime) / 86400.0
		inGracePeriod := daysSeeded < GracePeriodDays

		if inGracePeriod {
			keptSize += t.Size
			continue
		}

		if keptSize+t.Size > GlobalCapBytes {
			toDelete = append(toDelete, t)
		} else {
			keptSize += t.Size
		}
	}

	var totalSize int64
	for _, t := range torrents {
		totalSize += t.Size
	}

	fmt.Printf("Total Autobrr Size: %.2f GB\n", float64(totalSize)/(1024*1024*1024))
	fmt.Printf("Kept Size: %.2f GB / %.2f GB Limit\n", float64(keptSize)/(1024*1024*1024), float64(GlobalCapBytes)/(1024*1024*1024))
	fmt.Printf("Torrents to Delete: %d\n\n", len(toDelete))

	if len(toDelete) > 0 {
		fmt.Println("--- DELETION QUEUE ---")
		for _, t := range toDelete {
			days := float64(t.SeedingTime) / 86400.0
			score := getScore(t, now)
			gb := float64(t.Size) / (1024 * 1024 * 1024)

			name := t.Name
			if len(name) > 50 {
				name = string([]rune(name)[:50])
			}
			fmt.Printf("[%s...] Size: %.2fGB | Ratio: %.2f | Days: %.1f | Score: %.4f\n", name, gb, t.Ratio, days, score)
		}

		if !*dryRun {
			hashes := make([]string, len(toDelete))
			for i, t := range toDelete {
				hashes[i] = t.Hash
			}
			form := url.Values{}
			form.Set("hashes", strings.Join(hashes, "|"))
			form.Set("deleteFiles", "true")

			http.PostForm(QbitURL+"/api/v2/torrents/delete", form)
			fmt.Println("\nTorrents deleted.")
		} else {
			fmt.Println("\n[DRY RUN] No files were actually deleted.")
		}
	}
}
