Flat Shortlist website: files to upload to your GitHub repository

index.html           the website
listings.json        the listings, scores and photo links (replace this after each scan)
config.js            where the Supabase details go
supabase_setup.sql   paste once into Supabase's SQL Editor (do not need to upload, but harmless)

First-time setup
1. GitHub: open your repository, "Add file" > "Upload files", drag in index.html, listings.json and config.js, then "Commit changes".
2. GitHub: Settings > Pages > under "Build and deployment" choose "Deploy from a branch", branch "main", folder "/ (root)", Save.
   After a minute or two the site is live at https://<your-username>.github.io/<repository-name>/
3. Supabase: SQL Editor > paste supabase_setup.sql > change CHANGE-ME to your passcode > Run.
4. Supabase: Project Settings > API (or "API Keys") > copy the Project URL and the anon / publishable key.
5. GitHub: open config.js > pencil icon > paste the two values between the quotes > "Commit changes".
6. Send Mel and Roisin the site link and the passcode.

After each scan
Upload the new listings.json over the old one ("Add file" > "Upload files" > "Commit changes"). Nothing else changes.
