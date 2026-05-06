import '../../domain/avatar_v3/avatar_v3_layer.dart';

class AvatarV3InlineAssets {
  const AvatarV3InlineAssets._();

  static String? svgFor(AvatarV3Layer layer) {
    return _byId[layer.id] ?? _byPath[layer.assetPath];
  }

  static const Map<String, String> _byPath = <String, String>{
    'assets/avatar_v3/overlays/background_soft_studio.svg': backgroundSoftStudio,
    'assets/avatar_v3/base/body/meta_average_black_top.svg': bodyMetaAverageBlackTop,
    'assets/avatar_v3/base/neck/medium_tan.svg': neckMediumTan,
    'assets/avatar_v3/hair/ringlet_afro/back/long_copper.svg': ringletAfroBackLongCopper,
    'assets/avatar_v3/base/head/oval_tan.svg': headOvalTan,
    'assets/avatar_v3/base/head/ears_tan.svg': earsTan,
    'assets/avatar_v3/base/face/apple_meta_default.svg': faceAppleMetaDefault,
    'assets/avatar_v3/skin/freckles/nose_cheeks_medium.svg': frecklesNoseCheeksMedium,
    'assets/avatar_v3/facial_hair/none.svg': empty,
    'assets/avatar_v3/hair/ringlet_afro/front/long_copper.svg': ringletAfroFrontLongCopper,
    'assets/avatar_v3/accessories/glasses/round_clear.svg': glassesRoundClear,
    'assets/avatar_v3/overlays/lighting_soft.svg': lightingSoft,
  };

  static const Map<String, String> _byId = <String, String>{
    'background.soft_studio': backgroundSoftStudio,
    'body.meta.average.black_top': bodyMetaAverageBlackTop,
    'body.neck.medium.tan': neckMediumTan,
    'hair.ringlet_afro.back.long_copper': ringletAfroBackLongCopper,
    'head.oval.tan': headOvalTan,
    'ears.tan': earsTan,
    'face.apple_meta.default': faceAppleMetaDefault,
    'skin.freckles.nose_cheeks.medium': frecklesNoseCheeksMedium,
    'facial_hair.none': empty,
    'hair.ringlet_afro.front.long_copper': ringletAfroFrontLongCopper,
    'accessories.glasses.round_clear': glassesRoundClear,
    'lighting.soft': lightingSoft,
  };

  static const String empty = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512"></svg>
''';

  static const String backgroundSoftStudio = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <radialGradient id="bg" cx="33%" cy="18%" r="92%">
      <stop offset="0" stop-color="#fff7ed"/>
      <stop offset=".55" stop-color="#eadcf8"/>
      <stop offset="1" stop-color="#c7d2fe"/>
    </radialGradient>
  </defs>
  <rect width="512" height="512" rx="86" fill="url(#bg)"/>
  <ellipse cx="256" cy="462" rx="150" ry="30" fill="#111827" opacity=".14"/>
</svg>
''';

  static const String bodyMetaAverageBlackTop = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <path d="M174 318c-45 38-62 101-46 139 34 29 225 29 258 0 16-40-1-103-47-140-41 22-125 22-165 1z" fill="#171923"/>
  <path d="M197 324c-31 35-42 87-31 118 41 16 139 17 181 1 12-33 0-85-32-119-34 16-85 16-118 0z" fill="#262d3a" opacity=".6"/>
</svg>
''';

  static const String neckMediumTan = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <rect x="224" y="266" width="64" height="87" rx="27" fill="#b97849"/>
  <rect x="233" y="267" width="45" height="73" rx="21" fill="#d39a6a" opacity=".42"/>
</svg>
''';

  // Pass 2C: this back hair is deliberately split into left/right/back volume.
  // It no longer forms a continuous beard-like mass below the chin.
  static const String ringletAfroBackLongCopper = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <radialGradient id="copper" cx="38%" cy="22%" r="82%">
      <stop offset="0" stop-color="#f59e0b"/>
      <stop offset=".46" stop-color="#c85a0b"/>
      <stop offset="1" stop-color="#5a2209"/>
    </radialGradient>
    <radialGradient id="shadow" cx="50%" cy="50%" r="70%">
      <stop offset="0" stop-color="#8a3a0a"/>
      <stop offset="1" stop-color="#371405"/>
    </radialGradient>
  </defs>

  <!-- rear halo, visible around the head only -->
  <path d="M134 244c-22-92 30-169 120-174 94-5 150 71 128 174-11 51-42 81-72 90-30 9-43-4-54-16-11 12-26 25-55 16-32-10-57-40-67-90z"
        fill="url(#shadow)" opacity=".78"/>

  <!-- left side volume: starts at temple, falls beside neck, not over mouth/chin -->
  <path d="M143 160c-44 45-51 112-33 163 12 35 34 62 63 70 25 7 45-6 48-30 3-26-18-43-23-70-7-39 18-70 16-111-2-38-35-50-71-22z"
        fill="url(#copper)"/>

  <!-- right side volume: mirrored side fall, clear centre face -->
  <path d="M369 160c44 45 51 112 33 163-12 35-34 62-63 70-25 7-45-6-48-30-3-26 18-43 23-70 7-39-18-70-16-111 2-38 35-50 71-22z"
        fill="url(#copper)"/>

  <!-- top crown volume -->
  <path d="M157 164c25-64 88-92 143-81 45 9 79 42 91 82-50-31-111-39-170-24-24 6-45 14-64 23z"
        fill="url(#copper)"/>

  <!-- individual curl texture kept outside centre face -->
  <g fill="none" stroke="#f6ad3a" stroke-width="7" stroke-linecap="round" opacity=".62">
    <path d="M155 182c29-40 86-60 140-49"/>
    <path d="M126 246c10-44 38-82 76-102"/>
    <path d="M386 246c-10-44-38-82-76-102"/>
    <path d="M135 318c18 28 45 43 75 40"/>
    <path d="M377 318c-18 28-45 43-75 40"/>
    <path d="M181 127c-13 21-9 43 11 58"/>
    <path d="M329 127c14 22 11 45-8 61"/>
  </g>

  <!-- dark curl knots around perimeter only -->
  <g fill="#351205" opacity=".42">
    <circle cx="153" cy="175" r="13"/>
    <circle cx="187" cy="124" r="12"/>
    <circle cx="225" cy="102" r="13"/>
    <circle cx="272" cy="101" r="13"/>
    <circle cx="316" cy="120" r="12"/>
    <circle cx="359" cy="172" r="14"/>
    <circle cx="126" cy="257" r="12"/>
    <circle cx="390" cy="257" r="12"/>
    <circle cx="155" cy="351" r="12"/>
    <circle cx="357" cy="351" r="12"/>
  </g>
</svg>
''';

  static const String headOvalTan = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="skin" x1="174" y1="105" x2="332" y2="332">
      <stop offset="0" stop-color="#d99e6f"/>
      <stop offset=".58" stop-color="#bf7d4e"/>
      <stop offset="1" stop-color="#8e5837"/>
    </linearGradient>
  </defs>
  <path d="M168 213c0-82 36-126 88-126s88 44 88 126c0 77-38 127-88 127s-88-50-88-127z" fill="url(#skin)"/>
  <ellipse cx="215" cy="235" rx="34" ry="20" fill="#fb7185" opacity=".13"/>
  <ellipse cx="297" cy="235" rx="34" ry="20" fill="#fb7185" opacity=".12"/>
</svg>
''';

  static const String earsTan = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <ellipse cx="166" cy="220" rx="18" ry="35" fill="#ad7148"/>
  <ellipse cx="346" cy="220" rx="18" ry="35" fill="#ad7148"/>
</svg>
''';

  static const String faceAppleMetaDefault = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <path d="M211 184c15-10 32-10 47 0" stroke="#2b160a" stroke-width="8" stroke-linecap="round" fill="none"/>
  <path d="M267 184c15-10 32-10 47 0" stroke="#2b160a" stroke-width="8" stroke-linecap="round" fill="none"/>
  <ellipse cx="232" cy="212" rx="17" ry="11" fill="#fff"/>
  <ellipse cx="281" cy="212" rx="17" ry="11" fill="#fff"/>
  <circle cx="232" cy="212" r="8" fill="#4b2a18"/>
  <circle cx="281" cy="212" r="8" fill="#4b2a18"/>
  <circle cx="229" cy="209" r="3" fill="#fff"/>
  <circle cx="278" cy="209" r="3" fill="#fff"/>
  <path d="M258 221c-8 22-5 36 10 40" fill="none" stroke="#7c4b31" stroke-width="5" stroke-linecap="round" opacity=".5"/>
  <path d="M226 282c18 18 45 18 62 0" fill="none" stroke="#8b1e3f" stroke-width="7" stroke-linecap="round"/>
</svg>
''';

  static const String frecklesNoseCheeksMedium = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <g fill="#7c2d12" opacity=".45">
    <circle cx="214" cy="235" r="3"/><circle cx="229" cy="240" r="2.4"/><circle cx="244" cy="236" r="2.2"/>
    <circle cx="261" cy="237" r="2.4"/><circle cx="277" cy="241" r="2.7"/><circle cx="294" cy="235" r="3"/>
  </g>
</svg>
''';

  // Pass 2C: front hair is now only controlled crown/fringe curls.
  // It never drops over cheeks, jaw, mouth, or chin.
  static const String ringletAfroFrontLongCopper = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <defs>
    <linearGradient id="frontCopper" x1="181" y1="104" x2="334" y2="158">
      <stop offset="0" stop-color="#f59e0b"/>
      <stop offset=".55" stop-color="#c2410c"/>
      <stop offset="1" stop-color="#6f270b"/>
    </linearGradient>
  </defs>

  <!-- soft hairline crown sitting on head, not face -->
  <path d="M184 145c28-44 107-55 146-14"
        stroke="#5b2108" stroke-width="25" stroke-linecap="round" fill="none"/>
  <path d="M199 132c29-25 88-30 117-7"
        stroke="url(#frontCopper)" stroke-width="14" stroke-linecap="round" fill="none"/>

  <!-- small ringlets at temples only -->
  <g fill="none" stroke="#a63f0a" stroke-width="10" stroke-linecap="round">
    <path d="M184 166c-13 11-17 25-10 38"/>
    <path d="M328 166c14 11 18 25 10 39"/>
  </g>

  <!-- tiny curls across top/hairline, kept above eyebrows -->
  <g fill="none" stroke="#f59e0b" stroke-width="6" stroke-linecap="round" opacity=".78">
    <path d="M215 125c-10 13-5 25 9 30"/>
    <path d="M250 117c-12 13-8 26 7 32"/>
    <path d="M286 123c-12 12-9 25 6 31"/>
  </g>
</svg>
''';

  static const String glassesRoundClear = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <g fill="none" stroke="#111827" stroke-width="5" opacity=".86">
    <circle cx="232" cy="212" r="24"/>
    <circle cx="281" cy="212" r="24"/>
    <path d="M256 212h1"/>
    <path d="M208 209l-22-7"/>
    <path d="M305 209l22-7"/>
  </g>
</svg>
''';

  static const String lightingSoft = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 512 512">
  <ellipse cx="206" cy="125" rx="74" ry="38" fill="#ffffff" opacity=".10"/>
</svg>
''';
}
