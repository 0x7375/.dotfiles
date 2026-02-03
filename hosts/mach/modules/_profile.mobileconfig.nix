{ nextdns_id }:

''
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
    <dict>
      <key>PayloadDisplayName</key><string>System profile</string>
      <key>PayloadDescription</key><string></string>
      <key>PayloadIdentifier</key><string>nix</string>
      <key>PayloadScope</key><string>System</string>
      <key>PayloadType</key><string>Configuration</string>
      <key>PayloadUUID</key><string>04C48B35-5B4E-49EB-9043-C6108EE9D48D</string>
      <key>PayloadVersion</key><integer>1</integer>
      <key>PayloadContent</key>
      <array>
        <dict>
          <key>PayloadType</key><string>com.apple.applicationaccess</string>
          <key>PayloadVersion</key><integer>1</integer>
          <key>PayloadIdentifier</key><string>org.stayonsequoia.restrictions</string>
          <key>PayloadUUID</key><string>ECA22059-559B-4235-9DF2-328D895BE836</string>
          <key>PayloadEnabled</key><true/>
          <key>PayloadDisplayName</key><string>Delay major updates</string>

          <key>forceDelayedMajorSoftwareUpdates</key><true/>
          <key>enforcedSoftwareUpdateMajorOSDeferredInstallDelay</key><integer>90</integer>
        </dict>

        <dict>
          <key>DNSSettings</key>
          <dict>
            <key>DNSProtocol</key>
            <string>HTTPS</string>
            <key>ServerURL</key>
            <string>https://apple.dns.nextdns.io/${nextdns_id}/mach/Apple%20~macbook-air</string>
          </dict>
          <key>OnDemandRules</key>
          <array>
            <dict>
              <key>Action</key>
              <string>EvaluateConnection</string>
              <key>ActionParameters</key>
              <array>
                <dict>
                  <key>DomainAction</key>
                  <string>NeverConnect</string>
                  <key>Domains</key>
                  <array>
                    <string>captive.apple.com</string>
                    <string>dav.orange.fr</string>
                    <string>vvm.mobistar.be</string>
                    <string>vvm.mstore.msg.t-mobile.com</string>
                    <string>tma.vvm.mone.pan-net.eu</string>
                    <string>vvm.ee.co.uk</string>
                  </array>
                </dict>
              </array>
            </dict>
            <dict>
              <key>Action</key>
              <string>Connect</string>
            </dict>
          </array>
          <key>PayloadType</key>
          <string>com.apple.dnsSettings.managed</string>
          <key>PayloadIdentifier</key>
          <string>io.nextdns.${nextdns_id}.profile.dnsSettings.managed</string>
          <key>PayloadUUID</key>
          <string>A1E2F262-DB73-40F6-BD22-2E42A43A3C94</string>
          <key>PayloadDisplayName</key>
          <string>NextDNS</string>
          <key>PayloadOrganization</key>
          <string>nix</string>
          <key>PayloadVersion</key>
          <integer>1</integer>
        </dict>
      </array>
    </dict>
  </plist>
''
