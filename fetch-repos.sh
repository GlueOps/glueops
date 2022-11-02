#https://stackoverflow.com/a/68770988/4620962

gh repo list GlueOps --limit 1000 | while read -r repo _; do
  gh repo clone "$repo" "$repo" -- --depth=1 || {
    git -C $repo pull
  } &
done
