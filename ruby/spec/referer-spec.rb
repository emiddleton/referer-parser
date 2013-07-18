# Copyright (c) 2012-2013 Snowplow Analytics Ltd. All rights reserved.
#
# This program is licensed to you under the Apache License Version 2.0,
# and you may not use this file except in compliance with the Apache License Version 2.0.
# You may obtain a copy of the Apache License Version 2.0 at http://www.apache.org/licenses/LICENSE-2.0.
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the Apache License Version 2.0 is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the Apache License Version 2.0 for the specific language governing permissions and limitations there under.

# Author::    Yali Sassoon (mailto:support@snowplowanalytics.com)
# Copyright:: Copyright (c) 2012-2013 Snowplow Analytics Ltd
# License::   Apache License Version 2.0

require 'referer-parser'
require 'uri'

describe RefererParser::Referer do

  GOOGLE_ADWORDS_REFERER = 'http://www.google.com/aclk?sa=L&ai=CWue6b0jnUYDzDYWyiwL9kYCAD7aVhJUEnt26mEa-renlqgEIABABUKb2vZb5_____wFg8wHIAQGqBB9P0EowkrfNi1o0kJz_CWVxMxTYwj4WPXk3pAJHwiHlgAeWibQk&sig=AOD64_3ImJApRvUE9QOVXxgd_2t81Zojng&rct=j&q=teach%20biology%20online&ved=0CC4Q0Qw&adurl=https://classdo.com/en/?aw=6504a662-6fdf-11e2-9ff8-12315004a165'
  YAHOO_MAIL_REFERER = 'http://us-mg6.mail.yahoo.com/neo/launch?.rand=1uf03p3cv6lcs'
  OUTLOOK_EMAIL_REFERER = 'https://dub118.mail.live.com/default.aspx?id=64855'
  YAHOO_SEARCH_REFERER = 'http://us.yhs4.search.yahoo.com/yhs/search?hspart=avg&hsimp=yhs-ifm1&p=classdo&type=dis_ad&param1=cmFuZD0wLjgxNDY0NzQ1OTE4MTYxMyZwPXJWRExic01nRVB3YXVHSHhKaHg4U09KVXFwUkQxWWZhSzJHeEV5bDJYRWlzOXUtN3R0U2NlNmlFWUdZZnMtekVFOVRFSFVTam02M1piWmt3VmpLOVhrbm1iU1BZeG5DNTlseUp4cXlJQXdxMVVGWng2NzEybkhNS3BRN0FoYURuTUhSMUdtaVBlajVFbFp5VFNtdXZiVXhCQU5lY2E5QkdlaTBDTTYwUXdRZW45Q29wc0VHbVZrVnU0UUFnUlFzSG5aTFhIamdkVWEyRU5uVzNrSUdPR1FrdFhhMDluV3BoS2xYeENtZHZiem1uNGZvVXV2VDJ2Sy1QMS10SVZDQ3l4ZE5fbHhSeVBGWmg2cXA0NlRFMFlsM0I5emRSeGktaTJuZ0Nvb0JJNHpaX01nTUxHeUp0djdUOTI4YW9DQVVGRjFPUnpMWWlUUVBpQ2NGOWFlUmx6bWlQYUZ3LWNUZHFqdVFsTU1zaGtGd294aFdiMjR6a1VxRTlTdUlsM2F3VDBDNkFNaUwtUkJUUG9SUzQwSmVVcDVRZm1fcDFJOWwtX2NIZUgzWkNfd0ExJlNQPXlocyZjaG5sPWRpc19hZA==&param2=browser_search_provider&param3=dis_ad'
  GOOGLE_COM_REFERER   = 'http://www.google.com/search?q=gateway+oracle+cards+denise+linn&hl=en&client=safari&tbo=d&biw=768&bih=900&source=lnms&tbm=isch&ei=t9fTT_TFEYb28gTtg9HZAw&sa=X&oi=mode_link&ct=mode&cd=2&sqi=2&ved=0CEUQ_AUoAQ'
  GOOGLE_CO_UK_REFERER = 'http://www.google.co.uk/search?hl=en&client=safari&q=psychic+bazaar&oq=psychic+bazaa&aq=0&aqi=g1&aql=&gs_l=mobile-gws-serp.1.0.0.61498.64599.0.66559.12.9.1.1.2.2.2407.10525.6-2j0j1j3.6.0...0.0.DiYO_7K_ndg&mvs=0'
  FACEBOOK_COM_REFERER = 'http://groups.google.co.uk/l.php?u=http%3A%2F%2Fpsy.bz%2FLtPadV&h=MAQHYFyRRAQFzmokHhn3w4LGWVzjs7YwZGejw7Up5TqNHIw'
  TRUNCATED_REFERER = 'http://googleads.g.doubleclick.net/pagead/ads?client=ca-pub-9108147844898389&output=html&h=60&slotname=1720218904&w=468&lmt=1368485108&flash=11.7.700.169&url=http%3A%2F%2Fwww.bsaving.com%2Fprintable-online-target-coupons%3Futm_source%3Dbsaving_new_Email%2'

  # Successful extractions
  E1 = [
		["Google search #1",     "http://www.google.com/search", ["search","Google"]],
		["Google search #2",     "http://www.google.com/search?q=gateway+oracle+cards+denise+linn&hl=en&client=safari", ["search","Google","gateway oracle cards denise linn"]],
		["Google Adwords #1",    "http://www.google.com/aclk?sa=L&ai=fdjaklfdsafdsafdsafdsafdsafFDhsdgfdg&sig=fdsafds&rct=j&q=something%20something%20something&ved=fasfdsaf&adurl=http://example.com/",["search","Google Adwords","something something something"]],
    ["Powered by Google",    "http://isearch.avg.com/pages/images.aspx?q=tarot+card+change&sap=dsp&lang=en&mid=209215200c4147d1a9d6d1565005540b-b0d4f81a8999f5981f04537c5ec8468fd5234593&cid=%7B50F9298B-C111-4C7E-9740-363BF0015949%7D&v=12.1.0.21&ds=AVG&d=7%2F23%2F2012+10%3A31%3A08+PM&pr=fr&sba=06oENya4ZG1YS6vOLJwpLiFdjG91ICt2YE59W2p5ENc2c4w8KvJb5xbvjkj3ceMjnyTSpZq-e6pj7GQUylIQtuK4psJU60wZuI-8PbjX-OqtdX3eIcxbMoxg3qnIasP0ww2fuID1B-p2qJln8vBHxWztkpxeixjZPSppHnrb9fEcx62a9DOR0pZ-V-Kjhd-85bIL0QG5qi1OuA4M1eOP4i_NzJQVRXPQDmXb-CpIcruc2h5FE92Tc8QMUtNiTEWBbX-QiCoXlgbHLpJo5Jlq-zcOisOHNWU2RSHYJnK7IUe_SH6iQ.%2CYT0zO2s9MTA7aD1mNjZmZDBjMjVmZDAxMGU4&snd=hdr&tc=test1", ["search","Google","tarot card change"]],
		["Google Images search", "http://www.google.fr/imgres?q=Ogham+the+celtic+oracle&hl=fr&safe=off&client=firefox-a&hs=ZDu&sa=X&rls=org.mozilla:fr-FR:unofficial&tbm=isch&prmd=imvnsa&tbnid=HUVaj-o88ZRdYM:&imgrefurl=http://www.psychicbazaar.com/oracles/101-ogham-the-celtic-oracle-set.html&docid=DY5_pPFMliYUQM&imgurl=http://mdm.pbzstatic.com/oracles/ogham-the-celtic-oracle-set/montage.png&w=734&h=250&ei=GPdWUIePCOqK0AWp3oCQBA&zoom=1&iact=hc&vpx=129&vpy=276&dur=827&hovh=131&hovw=385&tx=204&ty=71&sig=104115776612919232039&page=1&tbnh=69&tbnw=202&start=0&ndsp=26&ved=1t:429,r:13,s:0,i:114&biw=1272&bih=826", ["search","Google Images","Ogham the celtic oracle"]],
		["Yahoo, search",        "http://es.search.yahoo.com/search;_ylt=A7x9QbwbZXxQ9EMAPCKT.Qt.?p=BIEDERMEIER+FORTUNE+TELLING+CARDS&ei=utf-8&type=685749&fr=chr-greentree_gc&xargs=0&pstart=1&b=11", ["search","Yahoo!","BIEDERMEIER FORTUNE TELLING CARDS"]],
		["Yahoo, Images search", "http://it.images.search.yahoo.com/images/view;_ylt=A0PDodgQmGBQpn4AWQgdDQx.;_ylu=X3oDMTBlMTQ4cGxyBHNlYwNzcgRzbGsDaW1n?back=http%3A%2F%2Fit.images.search.yahoo.com%2Fsearch%2Fimages%3Fp%3DEarth%2BMagic%2BOracle%2BCards%26fr%3Dmcafee%26fr2%3Dpiv-web%26tab%3Dorganic%26ri%3D5&w=1064&h=1551&imgurl=mdm.pbzstatic.com%2Foracles%2Fearth-magic-oracle-cards%2Fcard-1.png&rurl=http%3A%2F%2Fwww.psychicbazaar.com%2Foracles%2F143-earth-magic-oracle-cards.html&size=2.8+KB&name=Earth+Magic+Oracle+Cards+-+Psychic+Bazaar&p=Earth+Magic+Oracle+Cards&oid=f0a5ad5c4211efe1c07515f56cf5a78e&fr2=piv-web&fr=mcafee&tt=Earth%2BMagic%2BOracle%2BCards%2B-%2BPsychic%2BBazaar&b=0&ni=90&no=5&ts=&tab=organic&sigr=126n355ib&sigb=13hbudmkc&sigi=11ta8f0gd&.crumb=IZBOU1c0UHU", ["search","Yahoo! Images","Earth Magic Oracle Cards"]],
		["PriceRunner search",   "http://www.pricerunner.co.uk/search?displayNoHitsMessage=1&q=wild+wisdom+of+the+faery+oracle", ["search","PriceRunner","wild wisdom of the faery oracle"]],
		["Bing Images search",   "http://www.bing.com/images/search?q=psychic+oracle+cards&view=detail&id=D268EDDEA8D3BF20AF887E62AF41E8518FE96F08", ["search","Bing Images","psychic oracle cards"]],
		["IXquick search",       "https://s3-us3.ixquick.com/do/search", ["search","IXquick"]],
		["AOL search",           "http://aolsearch.aol.co.uk/aol/search?s_chn=hp&enabled_terms=&s_it=aoluk-homePage50&q=pendulums", ["search","AOL","pendulums"]],
		["Ask search",           "http://uk.search-results.com/web?qsrc=1&o=1921&l=dis&q=pendulums&dm=ctry&atb=sysid%3D406%3Aappid%3D113%3Auid%3D8f40f651e7b608b5%3Auc%3D1346336505%3Aqu%3Dpendulums%3Asrc%3Dcrt%3Ao%3D1921&locale=en_GB", ["search","Ask","pendulums"]],
		["Mail.ru search",       "http://go.mail.ru/search?q=Gothic%20Tarot%20Cards&where=any&num=10&rch=e&sf=20", ["search","Mail.ru","Gothic Tarot Cards"]],
		["Yandex search",        "http://images.yandex.ru/yandsearch?text=Blue%20Angel%20Oracle%20Blue%20Angel%20Oracle&noreask=1&pos=16&rpt=simage&lr=45&img_url=http%3A%2F%2Fmdm.pbzstatic.com%2Foracles%2Fblue-angel-oracle%2Fbox-small.png", ["search","Yandex Images","Blue Angel Oracle Blue Angel Oracle"]],
		["Twitter redirect",     "http://t.co/chrgFZDb", ["social","Twitter"]],
		["Facebook social",      "http://www.facebook.com/l.php?u=http%3A%2F%2Fwww.psychicbazaar.com&h=yAQHZtXxS&s=1", ["social","Facebook"]],
		["Facebook mobile",      "http://m.facebook.com/l.php?u=http%3A%2F%2Fwww.psychicbazaar.com%2Fblog%2F2012%2F09%2Fpsychic-bazaar-reviews-tarot-foundations-31-days-to-read-tarot-with-confidence%2F&h=kAQGXKbf9&s=1", ["social","Facebook"]],
		["Odnoklassniki",        "http://www.odnoklassniki.ru/dk?cmd=logExternal&st._aid=Conversations_Openlink&st.name=externalLinkRedirect&st.link=http%3A%2F%2Fwww.psychicbazaar.com%2Foracles%2F187-blue-angel-oracle.html", ["social","Odnoklassniki"]],
		["Tumblr social #1",     "http://www.tumblr.com/dashboard", ["social","Tumblr"]],
		["Tumblr w subdomain",   "http://psychicbazaar.tumblr.com/", ["social","Tumblr"]],
		["Yahoo, Mail",          "http://36ohk6dgmcd1n-c.c.yom.mail.yahoo.net/om/api/1.0/openmail.app.invoke/36ohk6dgmcd1n/11/1.0.35/us/en-US/view.html/0", ["email","Yahoo! Mail"]],
		["Outlook.com mail",     "http://co106w.col106.mail.live.com/default.aspx?rru=inbox", ["email","Outlook.com"]],
		["Orange Webmail",       "http://webmail1m.orange.fr/webmail/fr_FR/read.html?FOLDER=SF_INBOX&IDMSG=8594&check=&SORTBY=31", ["email","Orange Webmail"]],
		["Internal HTTP",        "http://www.snowplowanalytics.com/about/team", ["internal"]],
		["Internal HTTPS",       "https://www.snowplowanalytics.com/account/profile", ["internal"]]
  ]

  # Unknown referer URI
	E2 = [
		["Unknown referer #1",     "http://www.behance.net/gallery/psychicbazaarcom/2243272", ["unknown"]],
		["Unknown referer #2",     "http://www.wishwall.me/home", ["unknown"]],
		["Unknown referer #3",     "http://www.spyfu.com/domain.aspx?d=3897225171967988459", ["unknown"]],
		["Unknown referer #4",     "http://seaqueen.wordpress.com/", ["unknown"]],
		["Non-search Yahoo! site", "http://finance.yahoo.com", ["unknown","Yahoo!"]]
  ]

  # Unavoidable false positives
  E3 = [
		["Unknown Google service",       "http://xxx.google.com", ["search","Google"]],
		["Unknown Yahoo! service",       "http://yyy.yahoo.com", ["search","Yahoo!"]],
		["Non-search Google Drive link", "http://www.google.com/url?q=http://www.whatismyreferer.com/&sa=D&usg=ALhdy2_qs3arPmg7E_e2aBkj6K0gHLa5rQ", ["search","Google","http://www.whatismyreferer.com/"]]
  ]

  E1.each do |e|
    name, url, ref =* e
    it "should successfully extract \"#{name}\"" do
      r = RefererParser::Referers.get_referer(URI.parse(url))
      ['medium','source','term'].zip(ref).each do |k,v|
        r.send(k).should eql(v)
      end
    end
  end

  E2.each do |e|
    name, url, ref =* e
    it "should return unknown referer for #{name}" do
      r = RefererParser::Referers.get_referer(URI.parse(url))
      ['medium','source'].zip(ref).each do |k,v|
        r.send(k).should eql(v)
      end
    end
  end

  E3.each do |e|
    name, url, ref =* e
    it "should return a false positive for #{name}" do
      r = RefererParser::Referers.get_referer(URI.parse(url))
      ['medium','source','term'].zip(ref).each do |k,v|
        r.send(k).should eql(v)
      end
    end
  end

end
