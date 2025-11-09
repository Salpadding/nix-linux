-include cred.mk

sync_excludes = .git hardware-configuration.nix \
  doc conf modules scripts .ruby-lsp Makefile .vscode \
  local metacubexd .gitignore cred.mk Makefile secrets.example.json

mihomo_db_files = cache.db geoip.metadb

mkdir:
	mkdir -p opt/{lib,conf}/{mihomo,dnsmasq}

sync: FORCE
	rsync -azvp --delete $(foreach x,$(sync_excludes),--exclude $(x)) ./ "$(TARGET):$(DEST)/"
	for dir in {lib,conf}/{mihomo,dnsmasq}; do \
		rsync -azvp $(foreach x,$(mihomo_db_files),--exclude $(x)) ./opt/$${dir}/ "$(TARGET):/opt/$${dir}/"; \
	done
	$(foreach x,mihomo dnsmasq,echo 'chown -R $(x):$(x) /opt/{conf,lib}/$(x)' | ssh $(TARGET) bash;)


rebuild: sync
	ssh $(TARGET) 'NIX_DEBUG=1 nixos-rebuild switch --show-trace --keep-failed'

update/china-dns: mkdir FORCE
	./scripts/update-china-dns.rb -k $(GITHUB_TOKEN) -d opt/conf/dnsmasq/dns

update/mihomo: FORCE
	./scripts/build-clash-conf.rb -d opt/conf/mihomo -p router 
	cp opt/conf/mihomo/router.yaml opt/lib/mihomo/router.yaml

update/apnic: FORCE
	curl -o ./local/apnic.txt https://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest

dist/nftables.nft: FORCE
	./scripts/build-geoip.rb -t scripts/geoip.nft.erb -o $@ -s '$(abspath .)/local/apnic.txt'


update/all: update/china-dns update/mihomo update/apnic dist/nftables.nft

test/nft: sync
	ssh $(TARGET) 'nft -f $(DEST)/nftables.nft -c'



.PHONY: FORCE