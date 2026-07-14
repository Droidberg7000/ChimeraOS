# BlackBerry Package Source Index

## Android / Termux APK

Preferred official sources:
- Termux GitHub repo: https://github.com/termux/termux-app
- Termux:API GitHub repo: https://github.com/termux/termux-api
- F-Droid package page for Termux (preferred production source for stable installs)

Important notes:
- Termux maintainers warn not to mix APKs from different signing sources.
- GitHub builds are debuggable and signed with a shared test key.
- F-Droid is the safer normal-user source for production installs.

## BlackBerry OS legacy formats: ALX / COD / JAD / JAR

Useful source and format references:
- Format/install overview: http://www.blackberryrc.com/blackberry-tutorials/2010/1221/36.html
- Additional format/install guide: https://mhotspot.com/blog/how-to-install-applications-jar-cod-or-jad-on-blackberry/
- ALX/JAD conversion and loader notes: https://blackberry-su.livejournal.com/18109.html
- JAD/COD/JAR description notes: http://www.williamsmobile.co.uk/bbcod.htm
- JAR/JAD -> COD/ALX conversion with RAPC/JDE notes: https://jpgarcia.cl/2007/08/22/blackberry-%C2%BFcomo-cargar-un-jar-sin-usar-un-servidor-bes/
- BBSSH archive/source page: https://sourceforge.net/projects/bbssh/

Important notes:
- ALX is commonly used with Desktop Software / Desktop Manager.
- JAD often points to one or more COD files or a JAR.
- Many legacy apps are only available through archives, mirrors, or community repositories.

## BlackBerry 10 formats: BAR / APK

Useful source and format references:
- BB10 WebWorks repo: https://github.com/blackberry/bb10-webworks-framework
- BB10 APK/BAR sideload how-to: https://techpp.com/2013/03/29/how-to-sideload-android-apps-on-blackberry-10/
- BB10 10.2.1 direct APK support article: https://www.digit.in/features/apps/how-to-install-an-android-app-on-blackberry-10-2-1-phone-19721.html
- Community links page mentioning .bar/.apk sites: https://github-wiki-see.page/m/BerryFarm/berrymuch/wiki/Useful-links

Important notes:
- BAR is the native BB10 app format.
- APK support on BB10 varies by OS version and app compatibility.
- Community mirrors exist, but provenance and trust vary.

## Download policy

Before downloading any binary payload for installation:
1. Prefer official repos, official release pages, or widely trusted archives.
2. Record source URL, filename, size, and SHA-256.
3. Keep Android signing-source consistency for Termux and its plugins.
4. Treat random Telegram/forum mirrors as lower trust unless cross-verified.
