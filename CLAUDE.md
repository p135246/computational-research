# Plugin Maintenance

After any changes to plugin files, always:
1. Commit and push to git
2. Rezip: from `/Users/pavel/Library/CloudStorage/OneDrive-Personal/AI/`, run:
   ```bash
   rm -f ComputationalResearch/computational-research.zip && zip -r ComputationalResearch/computational-research.zip ComputationalResearch/ --exclude "ComputationalResearch/.git/*" --exclude "ComputationalResearch/.DS_Store" --exclude "ComputationalResearch/**/.DS_Store"
   ```
3. The zip is committed and pushed inside the repo (it is referenced in the README for download)
4. If the version was bumped, also update the version in `../claude-plugins/.claude-plugin/marketplace.json`, commit and push that repo too
