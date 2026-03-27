import React from "react";
import { existsSync } from "fs";
import { exec } from "child_process";
import { Action, ActionPanel, List, Icon, closeMainWindow } from "@vicinae/api";

const run = (cmd: string) => {
  closeMainWindow();
  exec(cmd);
};

const isBattery = existsSync("/sys/class/power_supply/BAT0");

type Item = { title: string; icon: Icon; action: () => void };

const items: Item[] = [
  { title: "Logout",    icon: Icon.Person,   action: () => run("loginctl terminate-user $USER") },
  { title: "Hibernate", icon: Icon.Moon,     action: () => run("systemctl hibernate") },
  { title: "Shutdown",  icon: Icon.Power,    action: () => run("systemctl poweroff") },
  { title: "Reboot",    icon: Icon.Repeat,  action: () => run("systemctl --no-wall reboot") },
  { title: "Firmware",  icon: Icon.Cog,     action: () => run("systemctl --no-wall reboot --firmware-setup") },
  ...(isBattery
    ? [{ title: "Lock", icon: Icon.Lock, action: () => run("loginctl lock-sessions") }]
    : [{
        title: "Windows", icon: Icon.Windows11, action: () => run(
          `ENTRY=$(efibootmgr | grep -i windows | grep -oP 'Boot\\K[0-9A-F]+' | head -1) && sudo efibootmgr --bootnext "$ENTRY" && systemctl --no-wall reboot`
        )
      }]
  )
];

export default function PowerMenu() {
  return (
    <List searchBarPlaceholder="POWER">
      {items.map(item => (
        <List.Item
          key={item.title}
          title={item.title}
          icon={item.icon}
          actions={
            <ActionPanel>
              <Action title={item.title} onAction={item.action} />
            </ActionPanel>
          }
        />
      ))}
    </List>
  );
}
