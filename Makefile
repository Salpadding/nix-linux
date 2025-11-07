-include cred.mk

sync: FORCE
	rsync -azvp \
  --exclude .git \
  --exclude hardware-configuration.nix \
  --exclude doc \
  --exclude conf \
  --exclude modules \
  --exclude scripts \
  --exclude .ruby-lsp \
  --exclude Makefile \
  ./ "$(TARGET):$(DEST)/"

rebuild:
	./scripts/update-and-rebuild.sh

update/china-dns: FORCE
	./scripts/update-china-dns.rb -k $(GITHUB_TOKEN) -d conf/dnsmasq/dns

update/mihomo: FORCE
	./scripts/build-clash-conf.rb -d conf/mihomo -p router 

update/apnic: FORCE
	curl -o ./local/apnic.txt https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest

test/nft: sync
	ssh $(TARGET) 'nft -f $(DEST)/nftables.nft -c'

dist/nftables.nft: FORCE
	./scripts/build-geoip.rb -t scripts/geoip.nft.erb -o $@ -s '$(abspath .)/local/apnic.txt'


.PHONY: FORCE