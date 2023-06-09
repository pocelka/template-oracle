Bitwarden setup (pre-requisite):
set env variables BW_CLIENTID and BW_CLIENTSECRET
bw login --apikey
bw unlock --raw
set env variable BW_SESSION=""

bw get item "Oracle - DB ATP1 - dev" | jq -r '.login.username'
bw get item "Oracle - DB ATP1 - dev" | jq -r '.fields[] | select (.name=="DB Pass") | .value'

