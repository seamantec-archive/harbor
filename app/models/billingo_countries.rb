module BillingoCountries
  def billingo_countries(code)

    countries = {
      af: 'Afganisztán',
      ax: 'Aland-szigetek ',
      al: 'Albánia',
      dz: 'Algéria',
      as: 'Amerikai Szamoa ',
      vi: 'Amerikai Virgin-szigetek ',
      ad: 'Andorra',
      ao: 'Angola',
      ai: 'Anguilla ',
      aq: 'Antarktisz',
      ag: 'Antigua és Barbuda',
      va: 'Apostoli Szentszék',
      ar: 'Argentína',
      aw: 'Aruba ',
      au: 'Ausztrália',
      at: 'Ausztria',
      um: 'Az Amerikai Egyesült Államok Külső Szigetei',
      az: 'Azerbajdzsán',
      bs: 'Bahama-szigetek',
      bh: 'Bahrein',
      bd: 'Banglades',
      bb: 'Barbados',
      by: 'Belarusz / Fehéroroszország',
      be: 'Belgium',
      bz: 'Belize',
      bj: 'Benin',
      bm: 'Bermuda ',
      bt: 'Bhután',
      gw: 'Bissau-Guinea',
      bo: 'Bolívia',
      ba: 'Bosznia-Hercegovina',
      bw: 'Botswana',
      bv: 'Bouvet-sziget ',
      br: 'Brazília',
      io: 'Brit Indiai-óceáni Terület',
      vg: 'Brit Virgin-szigetek ',
      bn: 'Brunei',
      bg: 'Bulgária',
      bf: 'Burkina Faso',
      bi: 'Burundi',
      cl: 'Chile',
      cy: 'Ciprus',
      cp: 'Clipperton ',
      km: 'Comore-szigetek',
      ck: 'Cook-szigetek ',
      cr: 'Costa Rica',
      td: 'Csád',
      cz: 'Csehország',
      dk: 'Dánia',
      za: 'Dél-Afrika',
      gs: 'Dél-Georgia és Déli-Sandwich-szigetek ',
      kr: 'Dél-Korea',
      dm: 'Dominika',
      do: 'Dominikai Köztársaság',
      dj: 'Dzsibuti',
      ec: 'Ecuador',
      gq: 'Egyenlítői-Guinea',
      us: 'Egyesült Államok',
      ae: 'Egyesült Arab Emírségek',
      uk: 'Egyesült Királyság',
      eg: 'Egyiptom',
      ci: 'Elefántcsontpart',
      er: 'Eritrea',
      kp: 'Észak-Korea',
      mp: 'Északi-Mariana-szigetek ',
      ee: 'Észtország',
      et: 'Etiópia',
      fk: 'Falkland-szigetek',
      fo: 'Feröer szigetek ',
      fj: 'Fidzsi-szigetek',
      fi: 'Finnország',
      tf: 'Francia Déli Területek ',
      gf: 'Francia Guyana ',
      pf: 'Francia Polinézia ',
      fr: 'Franciaország',
      ph: 'Fülöp-szigetek',
      ga: 'Gabon',
      gm: 'Gambia',
      gh: 'Ghána',
      gi: 'Gibraltár ',
      el: 'Görögország',
      gd: 'Grenada',
      gl: 'Grönland ',
      ge: 'Grúzia',
      gp: 'Guadeloupe ',
      gu: 'Guam ',
      gt: 'Guatemala',
      gn: 'Guinea',
      gy: 'Guyana',
      ht: 'Haiti',
      hm: 'Heard-sziget és McDonald-szigetek ',
      an: 'Holland Antillák ',
      nl: 'Hollandia',
      hn: 'Honduras',
      hk: 'Hongkong ',
      hr: 'Horvátország',
      in: 'India',
      id: 'Indonézia',
      iq: 'Irak',
      ir: 'Irán',
      ie: 'Írország',
      is: 'Izland',
      il: 'Izrael',
      jm: 'Jamaica',
      jp: 'Japán',
      ye: 'Jemen',
      jo: 'Jordánia',
      ky: 'Kajmán-szigetek ',
      kh: 'Kambodzsa',
      cm: 'Kamerun',
      ca: 'Kanada',
      cx: 'Karácsony-sziget ',
      qa: 'Katar',
      kz: 'Kazahsztán',
      tl: 'Kelet-Timor',
      ke: 'Kenya',
      cn: 'Kína',
      kg: 'Kirgizisztán',
      ki: 'Kiribati',
      cc: 'Kókusz-szigetek/Keeling-szigetek',
      co: 'Kolumbia',
      cg: 'Kongó',
      cd: 'Kongói Demokratikus Köztársaság',
      cf: 'Közép-afrikai Köztársaság',
      cu: 'Kuba',
      kw: 'Kuvait',
      la: 'Laosz',
      pl: 'Lengyelország',
      ls: 'Lesotho',
      lv: 'Lettország',
      lb: 'Libanon',
      lr: 'Libéria',
      ly: 'Líbia',
      li: 'Liechtenstein',
      lt: 'Litvánia',
      lu: 'Luxemburg',
      mk: 'Macedónia',
      mg: 'Madagaszkár',
      hu: 'Magyarország',
      mo: 'Makaó ',
      my: 'Malajzia',
      mw: 'Malawi',
      mv: 'Maldív-szigetek',
      ml: 'Mali',
      mt: 'Málta',
      ma: 'Marokkó',
      mh: 'Marshall-szigetek',
      mq: 'Martinique ',
      mr: 'Mauritánia',
      mu: 'Mauritius',
      yt: 'Mayotte ',
      mx: 'Mexikó',
      mm: 'Mianmar ',
      fm: 'Mikronézia',
      md: 'Moldova',
      mc: 'Monaco',
      mn: 'Mongólia',
      me: 'Montenegró',
      ms: 'Montserrat ',
      mz: 'Mozambik',
      na: 'Namíbia',
      nr: 'Nauru',
      de: 'Németország',
      np: 'Nepál',
      ni: 'Nicaragua',
      ne: 'Niger',
      ng: 'Nigéria',
      nu: 'Niue ',
      nf: 'Norfolk-sziget ',
      no: 'Norvégia',
      eh: 'Nyugat-Szahara ',
      it: 'Olaszország',
      om: 'Omán',
      am: 'Örményország',
      ru: 'Oroszország',
      pk: 'Pakisztán',
      pw: 'Palau',
      pa: 'Panama',
      pg: 'Pápua Új-Guinea',
      py: 'Paraguay',
      pe: 'Peru',
      pn: 'Pitcairn-szigetek ',
      pt: 'Portugália',
      pr: 'Puerto Rico ',
      re: 'Réunion ',
      ro: 'Románia',
      rw: 'Ruanda',
      kn: 'Saint Kitts és Nevis',
      lc: 'Saint Lucia',
      vc: 'Saint Vincent és Grenadine-szigetek',
      pm: 'Saint-Pierre és Miquelon',
      sb: 'Salamon-szigetek',
      sv: 'Salvador',
      sm: 'San Marino',
      st: 'São Tomé és Príncipe',
      sc: 'Seychelle-szigetek',
      sl: 'Sierra Leone',
      es: 'Spanyolország',
      lk: 'Srí Lanka',
      sr: 'Suriname',
      ch: 'Svájc',
      sj: 'Svalbard- és Jan Mayen-szigetek ',
      se: 'Svédország',
      ws: 'Szamoa',
      sa: 'Szaúd-Arábia',
      sn: 'Szenegál',
      sh: 'Szent Ilona ',
      rs: 'Szerbia',
      sg: 'Szingapúr',
      sy: 'Szíria',
      sk: 'Szlovákia',
      si: 'Szlovénia',
      so: 'Szomália',
      sd: 'Szudán',
      sz: 'Szváziföld',
      tj: 'Tádzsikisztán',
      tw: 'Tajvan ',
      tz: 'Tanzánia',
      th: 'Thaiföld',
      tg: 'Togo',
      tk: 'Tokelau-szigetek ',
      to: 'Tonga',
      tr: 'Törökország',
      tt: 'Trinidad és Tobago',
      tn: 'Tunézia',
      tm: 'Türkmenisztán',
      tc: 'Turks- és Caicos-szigetek ',
      tv: 'Tuvalu',
      ug: 'Uganda',
      nc: 'Új-Kaledónia ',
      nz: 'Új-Zéland',
      ua: 'Ukrajna',
      uy: 'Uruguay',
      uz: 'Üzbegisztán',
      vu: 'Vanuatu',
      ve: 'Venezuela',
      vn: 'Vietnam',
      wf: 'Wallis és Futuna ',
      zm: 'Zambia',
      zw: 'Zimbabwe',
      cv: 'Zöld-foki-szigetek'
    }
    return countries[code] if countries.has_key?(code)
    return ''
  end
end