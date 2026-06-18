# ════════════════════════════════════════════════════════════════════════
#  Oppretter veiledningssiden "Slik jobber du i skyen"
#  Kjøres per kunde. Rediger KUN innholdsdelen lenger ned.
# ════════════════════════════════════════════════════════════════════════

# ── 1. KONFIGURASJON ─────────────────────────────────────────────────────
param(
    [Parameter(Mandatory)] [string] $SiteUrl,                       # https://kunde.sharepoint.com/sites/Intranett
    [Parameter(Mandatory)] [string] $ClientId,                      # App-ID-en til din egen Entra-app
    [string] $CustomerName   = "din bedrift",
    [string] $SupportContact = "IT-support (sett inn e-post/telefon)"
)

$pageName    = "Slik Jobber du i skyen"
$pageTitle   = "Slik jobber du i skyen"
$publishDate = Get-Date -Format "dd.MM.yyyy"     # stemples automatisk ved hver kjøring


# ── 2. INNHOLD  (← det eneste du trenger å redigere) ─────────────────────

$introHtml = @"
<p>Velkommen! Denne siden gir deg en <b>grunnleggende forståelse</b> av hvordan du jobber i
skyen hos <b>$CustomerName</b> – med SharePoint og OneDrive. Du trenger ingen forkunnskaper.</p>
<p><i>Sist oppdatert: <b>$publishDate</b>. Microsoft 365 oppdateres jevnlig, så enkelte knapper,
navn og skjermbilder kan se litt annerledes ut enn beskrevet her.</i></p>
"@

$hvaHtml = @"
<h2>☁️ Hva er SharePoint og OneDrive?</h2>
<p>Begge er en del av Microsoft 365 og lar deg lagre filer trygt i skyen – tilgjengelig fra
PC, nettleser og mobil, med automatisk lagring, versjonshistorikk og sikkerhetskopi.</p>
<ul>
<li><b>SharePoint</b> er bedriftens <b>felles</b> plattform for å lagre, dele og samarbeide om
filer. Organisert i <i>områder</i> for team og avdelinger.</li>
<li><b>OneDrive</b> er din <b>personlige</b> fillagring – dine egne arbeidsfiler som ingen
andre ser før du velger å dele dem.</li>
</ul>
"@

$sharePointHtml = @"
<h2>🏢 SharePoint</h2>
<ul>
<li>Felles område for team, avdeling eller hele bedriften</li>
<li>Eies av organisasjonen</li>
<li>Mange brukere med ulik tilgang</li>
<li>For dokumenter <b>flere</b> skal finne og bruke</li>
<li>Organisert i <b>dokumentbiblioteker</b></li>
</ul>
"@

$oneDriveHtml = @"
<h2>👤 OneDrive</h2>
<ul>
<li>Din personlige lagringsplass</li>
<li>Du eier den selv</li>
<li>Bare du – helt til du deler noe</li>
<li>For kladder, utkast og personlige arbeidsfiler</li>
<li>Som din egen mappe i skyen</li>
</ul>
"@

$regelHtml = @"
<p><b>💡 Tommelfingerregel:</b> Er filen bare din? → OneDrive. Skal andre kunne bruke den? → SharePoint.</p>
"@

$navSpHtml = @"
<h2>🧭 Slik navigerer du i SharePoint</h2>
<ol>
<li>Gå til <b>office.com</b> → <b>app-velgeren</b> (vaffel-ikonet øverst til venstre) → <b>SharePoint</b>.</li>
<li>På <b>SharePoint-startsiden</b> ser du områdene du følger og besøker ofte.</li>
<li>Inne på et område: bruk <b>venstremenyen</b> for å bytte mellom sider og biblioteker.</li>
<li><b>«Innhold på området»</b> viser alt området inneholder.</li>
<li>Klikk <b>Følg</b> (stjernen) for å feste et område du bruker ofte.</li>
<li>Bruk <b>søkefeltet</b> øverst for å finne filer på tvers av områder.</li>
</ol>
"@

$navOdHtml = @"
<h2>🧭 Slik navigerer du i OneDrive</h2>
<ol>
<li>Gå til <b>office.com</b> → app-velgeren → <b>OneDrive</b> (eller klikk det blå <b>skyikonet</b> i oppgavelinjen).</li>
<li><b>Mine filer</b> = alt ditt eget.</li>
<li><b>Delt</b> = filer andre har delt med deg.</li>
<li><b>Favoritter</b> = filer du har merket for rask tilgang.</li>
<li><b>Papirkurv</b> = slettede filer (gjenopprettes i opptil 93 dager).</li>
</ol>
"@

$bibliotekHtml = @"
<h2>📚 Bytte mellom dokumentbiblioteker</h2>
<p>Et SharePoint-område kan ha <b>flere biblioteker</b> (f.eks. Salg, Delelager og Bilder hver for seg).</p>
<ul>
<li>Bytt mellom dem via <b>venstremenyen</b> eller <b>«Innhold på området»</b>.</li>
<li>Inni et bibliotek bruker du <b>brødsmulestien</b> øverst for å bevege deg opp og ned i mappene.</li>
<li>Klikk en <b>mappe</b> for å gå inn; klikk et navn i stien for å gå tilbake.</li>
</ul>
"@

$snarveiHtml = @"
<h2>📌 Legge til snarvei til OneDrive</h2>
<p>En snarvei gjør at du når en SharePoint-mappe rett fra din egen OneDrive – på alle enheter.</p>
<ol>
<li>Åpne biblioteket eller mappen i SharePoint.</li>
<li>Merk mappen du vil ha rask tilgang til.</li>
<li>Klikk <b>«Legg til snarvei til OneDrive»</b> i verktøylinjen øverst.</li>
<li>Snarveien dukker opp under <b>Mine filer</b> i OneDrive, med et lite <b>lenke-ikon</b>.</li>
<li>Nå når du mappen fra nettleser, mobil-appen og Filutforsker – uten å synkronisere.</li>
</ol>
"@

$syncHtml = @"
<h2>🔄 Synkroniser vs. 📌 Legg til snarvei – hva er forskjellen?</h2>
<p>Begge gir deg tilgang til SharePoint-filer i Filutforsker, men de fungerer ulikt:</p>
<table border="1" cellpadding="8" cellspacing="0" style="border-collapse:collapse;width:100%">
<tr style="background-color:#f3f3f3">
<th>&nbsp;</th><th>🔄 Synkroniser</th><th>📌 Legg til snarvei</th></tr>
<tr><td><b>Hvor det vises</b></td><td>Egen node i Filutforsker (under bedriftsnavnet)</td><td>Inne i din OneDrive-mappe</td></tr>
<tr><td><b>Følger med mellom enheter</b></td><td>Nei – settes opp på hver PC</td><td>Ja – følger OneDrive overalt</td></tr>
<tr><td><b>Mobil/nett</b></td><td>Nei</td><td>Ja</td></tr>
<tr><td><b>Anbefalt for de fleste</b></td><td>Sjeldnere</td><td><b>Ja</b></td></tr>
</table>
<p><b>💡 Anbefaling:</b> Bruk <b>«Legg til snarvei»</b> i de fleste tilfeller. <b>Synkroniser</b> passer best
når du trenger en hel mappe fast tilgjengelig lokalt på én bestemt PC.</p>
"@

$faqHtml = @"
<h2>❓ Ofte stilte spørsmål</h2>
<h3>Hvor mye lagringsplass har jeg?</h3>
<p>I OneDrive har du vanligvis rikelig med plass (ofte 1 TB) med en Microsoft 365-lisens. Usikker? Kontakt IT.</p>
<h3>Hva skjer hvis jeg sletter en fil ved et uhell?</h3>
<p>Ingen panikk – den havner i <b>Papirkurven</b> og kan gjenopprettes i opptil <b>93 dager</b>.</p>
<h3>Kan jeg jobbe uten internett?</h3>
<p>Ja. Filer du har gjort tilgjengelige offline kan redigeres uten nett – endringene <b>synkroniseres automatisk</b> når du er på nett igjen.</p>
<h3>Kan jeg åpne filene fra mobilen eller en annen PC?</h3>
<p>Ja. Alt ligger i skyen. Logg inn på <b>office.com</b> eller bruk OneDrive- og Office-appene.</p>
<h3>Hvorfor ser jeg sky-ikoner og grønne haker på filene?</h3>
<p>Det er <b>Filer ved behov</b>: <b>skyikon</b> = kun i skyen (sparer plass), <b>grønn hake</b> = også lokalt. Skyfiler lastes ned automatisk når du åpner dem.</p>
<h3>Er filene mine trygge?</h3>
<p>Ja – de lagres sikkert i Microsoft 365-skyen med sikkerhetskopi og versjonshistorikk. Lagre i skyen, <b>ikke</b> lokalt på C:.</p>
<h3>Hvorfor dele en lenke i stedet for vedlegg?</h3>
<p>Med en <b>lenke</b> jobber alle i <b>samme</b> fil – du slipper mange ulike versjoner på avveie.</p>
<h3>Hvem kan se filene i min OneDrive?</h3>
<p>Bare deg – helt til du selv velger å dele noe.</p>
"@

$supportHtml = @"
<h2>🆘 Trenger du hjelp?</h2>
<ul>
<li><b>Søk:</b> Bruk søkefeltet øverst for å finne filer på tvers av områder.</li>
<li><b>Kontakt:</b> $SupportContact</li>
</ul>
"@


# ── 3. SIDENS STRUKTUR  (rekkefølge + layout i ett blikk) ────────────────
$sections = @(
    @{ Template = 'OneColumn'; Columns = @($introHtml) },
    @{ Template = 'OneColumn'; Columns = @($hvaHtml) },
    @{ Template = 'TwoColumn'; Columns = @($sharePointHtml, $oneDriveHtml) },
    @{ Template = 'OneColumn'; Columns = @($regelHtml) },
    @{ Template = 'OneColumn'; Columns = @($navSpHtml) },
    @{ Template = 'OneColumn'; Columns = @($navOdHtml) },
    @{ Template = 'OneColumn'; Columns = @($bibliotekHtml) },
    @{ Template = 'OneColumn'; Columns = @($snarveiHtml) },
    @{ Template = 'OneColumn'; Columns = @($syncHtml) },
    @{ Template = 'OneColumn'; Columns = @($faqHtml) },
    @{ Template = 'OneColumn'; Columns = @($supportHtml) }
)


# ── 4. BYGG SIDEN  (motoren – trenger normalt ingen endring) ─────────────
Connect-PnPOnline -Url $SiteUrl -ClientId $ClientId -Interactive

Remove-PnPPage -Identity $pageName -Force -ErrorAction SilentlyContinue
Add-PnPPage    -Name $pageName -LayoutType Article

$i = 0
foreach ($section in $sections) {
    $i++
    Add-PnPPageSection -Page $pageName -SectionTemplate $section.Template
    $c = 0
    foreach ($html in $section.Columns) {
        $c++
        Add-PnPPageTextPart -Page $pageName -Section $i -Column $c -Text $html
    }
}

Set-PnPPage -Identity $pageName -Title $pageTitle -Publish
Write-Host "✅ '$pageTitle' er publisert: $SiteUrl/SitePages/$pageName.aspx ($publishDate)"