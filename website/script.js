// script.js
// This script fetches the latest release from GitHub
// and updates the download button with the .dmg asset.
// Replace `owner/repo` below with your actual repository.

(async () => {
    const repo = 'major-katsurAGI/corner'; // e.g., 'acme/corner'

    try {
        const response = await fetch(`https://api.github.com/repos/${repo}/releases/latest`);
        if (!response.ok) throw new Error('Could not fetch release info');

        const release = await response.json();
        const zipAsset = release.assets.find(a => a.name.toLowerCase().endsWith('.zip'));
        if (zipAsset) {
            const btn = document.getElementById('download-btn');
            btn.href = zipAsset.browser_download_url;
            btn.setAttribute('download', zipAsset.name);
        }
    } catch (err) {
        console.error(err);
    }
})();
