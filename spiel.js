const puppeteer = require('puppeteer');
const PuppeteerHar = require('puppeteer-har');

function delay(timeout) {
  return new Promise((resolve) => {
    setTimeout(resolve, timeout);
  });
}

(async () => {
  const browser = await puppeteer.launch({ ignoreHTTPSErrors: true,
headless: false });
  const page = await browser.newPage();
  await page.setViewport({ width: 2000, height: 1200 });

  const har = new PuppeteerHar(page);
  await har.start({ path: 'spiel.har',  saveResponse: true });

  // Login
  await page.goto('https://spiel.digital/en/games/', { waitUntil:
'networkidle2' });
  await har.stop();
  await browser.close();

})();
