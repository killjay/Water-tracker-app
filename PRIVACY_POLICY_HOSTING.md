# Privacy Policy Hosting Setup Guide

This guide explains how to host your privacy policy on GitHub Pages for free.

## Quick Start

Your privacy policy is ready to be hosted! Follow these steps:

### 1. Commit Files to Git

```bash
git add PRIVACY_POLICY.md docs/
git commit -m "Add privacy policy for Play Store submission"
git push origin main
```

### 2. Create GitHub Repository (if not already done)

1. Go to [GitHub](https://github.com) and sign in
2. Click the "+" icon in the top right and select "New repository"
3. Name it: `water-tracker` (or your preferred name)
4. Make it **Public** (required for GitHub Pages)
5. Don't initialize with README (you already have one)
6. Click "Create repository"

### 3. Push to GitHub

```bash
# If you haven't added a remote yet:
git remote add origin https://github.com/your-username/water-tracker.git

# Push your code:
git push -u origin main
```

### 4. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** (top menu)
3. Scroll down to **Pages** (left sidebar)
4. Under "Source", select:
   - **Branch**: `main`
   - **Folder**: `/docs`
5. Click **Save**
6. Wait 1-2 minutes for deployment

### 5. Access Your Privacy Policy

Your privacy policy will be available at:

```
https://your-username.github.io/water-tracker/privacy-policy.html
```

Replace `your-username` with your actual GitHub username.

### 6. Update Play Store Listing

Use this URL in your Google Play Console:

```
https://your-username.github.io/water-tracker/privacy-policy.html
```

Paste it in the "Privacy Policy" field under **Store Presence** > **Store Listing**.

## Files Created

- **`PRIVACY_POLICY.md`**: Markdown version for repository viewing
- **`docs/privacy-policy.html`**: Beautiful HTML version for public hosting
- **`docs/index.html`**: Redirects to privacy policy

## Customization

Before publishing, update the following placeholders in both files:

### Email Address
Replace `[your-email@example.com]` with your actual support email.

### GitHub URL
Replace `your-username` with your GitHub username in:
- Privacy policy contact section
- README.md links
- This guide

### Company/Developer Name (Optional)
If you want to add your company name or developer name, update the footer in `privacy-policy.html`.

## Testing

After GitHub Pages is enabled, test your privacy policy:

1. Visit the URL in your browser
2. Check that all sections display correctly
3. Verify links work (Firebase, Google policies)
4. Test on mobile devices
5. Ensure the page is accessible without authentication

## Updating the Privacy Policy

To update the policy:

1. Edit `docs/privacy-policy.html`
2. Update the "Last Updated" date
3. Commit and push changes:
   ```bash
   git add docs/privacy-policy.html
   git commit -m "Update privacy policy"
   git push
   ```
4. Changes will appear within 1-2 minutes

## Alternative Hosting Options

If you don't want to use GitHub Pages, you can host the privacy policy on:

- **Firebase Hosting**: Free hosting with your Firebase project
- **Netlify**: Free static site hosting
- **Vercel**: Free hosting for static sites
- **Your own website**: If you have one

## Troubleshooting

### GitHub Pages not working?
- Ensure repository is **Public**
- Check that `/docs` folder is selected in Pages settings
- Wait a few minutes for initial deployment
- Clear browser cache

### 404 Error?
- Verify the file exists in `docs/privacy-policy.html`
- Check that you pushed the `docs` folder to GitHub
- Ensure branch is set to `main` in Pages settings

### Need Help?
- GitHub Pages documentation: https://docs.github.com/pages
- Check your repository's Actions tab for build errors

## Security Notes

- Privacy policy is public (as required by Play Store)
- Don't include any private information
- Keep email address visible for user contact
- Update date whenever you make changes

## Play Store Requirements Met

✓ Privacy policy on publicly accessible URL  
✓ Explains data collection clearly  
✓ Mentions Google Sign-In  
✓ Describes Firebase usage  
✓ Lists data types collected  
✓ Explains data security measures  
✓ Provides contact information  
✓ Mobile-responsive design  

Your privacy policy is ready for Play Store submission!
