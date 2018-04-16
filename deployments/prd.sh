wget -O /tmp/packer.zip https://releases.hashicorp.com/packer/1.2.2/packer_1.2.2_linux_amd64.zip
wget -O /tmp/terraform.zip https://releases.hashicorp.com/terraform/0.11.7/terraform_0.11.7_linux_amd64.zip?_ga = 2.142984049.552417044.1523847625-358755134.1523847625
sudo unzip /tmp/packer.zip -d /bin
sudo unzip /tmp/terraform.zip -d /bin

packer validate deployments/template.json &&
packer build deployments/template.json &&

export TF_VAR_image_id=$(curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer $DIGITALOCEAN_API_TOKEN" "https://api.digitalocean.com/v2/images?private=true" | jq ."images[] | select(.name == \"voltor-image-$CIRCLE_BUILD_NUM\") | .id") &&

echo "Got the image id of the new digital ocean image" &&
echo $TF_VAR_image_id &&

cd infra && terraform init && terraform apply && cd .. &&

git add infra && git commit -m "Deployed $CIRCLE_BUILD NUM [skip ci]" &&
git push origin master

echo "Deployed and saved!" &&
echo "Now deleting the image previously created" &&
