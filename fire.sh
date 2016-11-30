#! /bin/bash

ID_RSA_PUB='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDSf0cPclIWxya1FBWD/ozmW/UcyOV7C/+DiNuAmFKi5D/zOPaKYYxjtASMQRI82QQcnq3qUAkMNo7ptkNLjKUdOnMQiI20CVcjNvKU+3wICWty/oOudzkPk94xXYRK2IfFzxKlG1WWww1D3oi/5Q3r9UUIvE26cM5gjR1aDdJcgcZRN2yNiB8R2ttrIhV2XQ0M9AGAzOA+HWiuLFKaJ8iiKHhZoeJPaymY9VYYsuIZXotytxRIR58aYcxtX0dtBuCeGuPVdJdHh5WAkqBXLZ5HdGB8GdBDzgmu8lDFvczgLbMcKRqLyzH2vHHXS+gNuuJieECgV1WvFcT19v3VmDRgk0s82ris8+Pmo6GwJs4gE9UzWr7ye+Dicu/kkhIUn91c4+kKgL/amxV5XYv9wUhNgbsugzL/KJ7Ja+TINR6NSLJReit/3UPPrhtFrH0O/NPijPe8CvJNeQCEDZ2Sf5EeoK22MAC6KAs4pJmFUeynVSYH4LIqA4AAtfEoqMXs0HwBrhdAxyWRgxiyqliWJva1wGMljB0rHUvZdx2SH98gWIuTBfiQVl2tvMIkOlxh5cPkTLW1l32ZRFOFNxZACitgPhDnFfUSo1lyM+OJaVkAjHdmFTcc2TQ12A0CvoeCySrE5UsAuods1ihi1z2ljfqICGgSabKfcPMapsV4eTzyZw== g@briel.ca'


UUID=$(uuidgen)
UUID_array=(${UUID//-/ })
vm_name=${UUID_array[0]}
pw=${UUID_array[1]}


payload=$(printf '{
  "name": "%s",
  "region": "sfo1",
  "size": "1gb",
  "image": "ubuntu-16-04-x64",
  "ssh_keys": null,
  "backups": false,
  "ipv6": true,
  "user_data": "#!/bin/bash
  bash <(wget -qO- https://github.com/gabrielgrant/k8s-quickstart/blob/master/launch.sh?raw=true)
  echo root:%s | chpasswd
  ",
  "private_networking": null,
  "volumes": null,
  "tags": [
    "pulted"
  ]
}' "$vm_name" "$pw")


echo "$payload"

create=$(curl -X POST -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" -d "$payload" "https://api.digitalocean.com/v2/droplets")
echo $create | env python -m "json.tool"
vm_id=$(echo $create | env python -c "
import sys
import json
print json.load(sys.stdin)['droplet']['id']
")

echo "VM ID: $vm_id"

curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $TOKEN" "https://api.digitalocean.com/v2/droplets/$vm_id" | env python -m 'json.tool'

echo "log in with ssh root@$IP and password $pw"
