{
  pkgs,
  lib,
  config,
  ...
}:

let
  reminders = [
    {
      time = "22:30:00";
      message = "22h30 -> 7-8h de sommeil c'est bien, casse toi";
    }
    {
      time = "23:00:00";
      message = "Ahah trop bizarre t'as pas eu ma notif^^ Ça bug ou quoi ? :P ;D xD lol";
    }
    {
      time = "23:30:00";
      message = "Il est 23h30 mon gars";
    }
    {
      time = "00:00:00";
      message = "Les dents, pipi et au lit";
    }
    {
      time = "00:30:00";
      message = "Une bonne raison de perdre du sommeil ? Je pense pas hein";
    }
    {
      time = "01:00:00";
      message = "Les raisons de perdre du sommeil en question:";
    }
    {
      time = "01:30:00";
      message = "C'est faisable demain faut réfléchir frérot";
    }
    {
      time = "02:00:00";
      message = "Pov: je suis abruti et j'ai un rythme de merde";
    }
    {
      time = "02:30:00";
      message = "Va te coucher gros con";
    }
    {
      time = "03:00:00";
      message = "Moins de sommeil -> journée de merde";
    }
    {
      time = "03:30:00";
      message = "C'est toujours pas assez important va te coucher";
    }
    {
      time = "04:00:00";
      message = "IL EST 4H TA MERE";
    }
    {
      time = "04:30:00";
      message = "Oui moi j'adore avoir un horrible rythme de vie c'est super";
    }
    {
      time = "05:00:00";
      message = "Zone de non-retour, débile extrême détecté";
    }
  ];

  safeId = t: builtins.replaceStrings [ ":" ] [ "-" ] t;

  mkReminder =
    { time, message }:
    {
      systemd.user.services."sleep-reminder-${safeId time}" = {
        description = "Sleep reminder for ${time}";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${pkgs.libnotify}/bin/notify-send -a sleep -i moon 'Faut dormir' ${lib.escapeShellArg message}";
        };
      };

      systemd.user.timers."sleep-reminder-${safeId time}" = {
        wantedBy = [ "timers.target" ];
        partOf = [ "sleep-reminder-${safeId time}.service" ];
        timerConfig = {
          OnCalendar = "*-*-* ${time}";
          Persistent = false;
        };
      };
    };
  cfg = config.me;
in
lib.mkIf (cfg.wm.enable && cfg.sleep.enable) (lib.mkMerge (map mkReminder reminders))
