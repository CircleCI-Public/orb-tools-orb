touch .yamllint || true
cat \<< EOF > .yamllint
extends: relaxed

rules:
    line-length:
        max: 200
        allow-non-breakable-inline-mappings: true

EOF