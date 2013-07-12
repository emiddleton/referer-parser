package referer

import (
  "testing"
	"net/url"
)

type testUrl struct {
	Name string
	Url  *url.URL
	Ref  Referer
}

func Parse(url_str string)(new_url *url.URL){
	new_url,_ = url.Parse(url_str)
	return new_url
}

var (
	e1 = []testUrl{
		{"Google search #1",Parse("http://www.google.com/search"),Referer{"search","Google",""}},
		{"Google search #2",Parse("http://www.google.com/search?q=gateway+oracle+cards+denise+linn&hl=en&client=safari"),Referer{"search","Google","gateway oracle cards denise linn"}},
		{"Powered by Google",Parse("http://isearch.avg.com/pages/images.aspx?q=tarot+card+change&sap=dsp&lang=en&mid=209215200c4147d1a9d6d1565005540b-b0d4f81a8999f5981f04537c5ec8468fd5234593&cid=%7B50F9298B-C111-4C7E-9740-363BF0015949%7D&v=12.1.0.21&ds=AVG&d=7%2F23%2F2012+10%3A31%3A08+PM&pr=fr&sba=06oENya4ZG1YS6vOLJwpLiFdjG91ICt2YE59W2p5ENc2c4w8KvJb5xbvjkj3ceMjnyTSpZq-e6pj7GQUylIQtuK4psJU60wZuI-8PbjX-OqtdX3eIcxbMoxg3qnIasP0ww2fuID1B-p2qJln8vBHxWztkpxeixjZPSppHnrb9fEcx62a9DOR0pZ-V-Kjhd-85bIL0QG5qi1OuA4M1eOP4i_NzJQVRXPQDmXb-CpIcruc2h5FE92Tc8QMUtNiTEWBbX-QiCoXlgbHLpJo5Jlq-zcOisOHNWU2RSHYJnK7IUe_SH6iQ.%2CYT0zO2s9MTA7aD1mNjZmZDBjMjVmZDAxMGU4&snd=hdr&tc=test1"),Referer{"search","Google","tarot card change"}},
		{"Google Images search",Parse("http://www.google.fr/imgres?q=Ogham+the+celtic+oracle&hl=fr&safe=off&client=firefox-a&hs=ZDu&sa=X&rls=org.mozilla:fr-FR:unofficial&tbm=isch&prmd=imvnsa&tbnid=HUVaj-o88ZRdYM:&imgrefurl=http://www.psychicbazaar.com/oracles/101-ogham-the-celtic-oracle-set.html&docid=DY5_pPFMliYUQM&imgurl=http://mdm.pbzstatic.com/oracles/ogham-the-celtic-oracle-set/montage.png&w=734&h=250&ei=GPdWUIePCOqK0AWp3oCQBA&zoom=1&iact=hc&vpx=129&vpy=276&dur=827&hovh=131&hovw=385&tx=204&ty=71&sig=104115776612919232039&page=1&tbnh=69&tbnw=202&start=0&ndsp=26&ved=1t:429,r:13,s:0,i:114&biw=1272&bih=826"),Referer{"search","Google Images","Ogham the celtic oracle"}},
		{"Yahoo, search",Parse("http://es.search.yahoo.com/search;_ylt=A7x9QbwbZXxQ9EMAPCKT.Qt.?p=BIEDERMEIER+FORTUNE+TELLING+CARDS&ei=utf-8&type=685749&fr=chr-greentree_gc&xargs=0&pstart=1&b=11"),Referer{"search","Yahoo!","BIEDERMEIER FORTUNE TELLING CARDS"}},
		{"Yahoo, Images search",Parse("http://it.images.search.yahoo.com/images/view;_ylt=A0PDodgQmGBQpn4AWQgdDQx.;_ylu=X3oDMTBlMTQ4cGxyBHNlYwNzcgRzbGsDaW1n?back=http%3A%2F%2Fit.images.search.yahoo.com%2Fsearch%2Fimages%3Fp%3DEarth%2BMagic%2BOracle%2BCards%26fr%3Dmcafee%26fr2%3Dpiv-web%26tab%3Dorganic%26ri%3D5&w=1064&h=1551&imgurl=mdm.pbzstatic.com%2Foracles%2Fearth-magic-oracle-cards%2Fcard-1.png&rurl=http%3A%2F%2Fwww.psychicbazaar.com%2Foracles%2F143-earth-magic-oracle-cards.html&size=2.8+KB&name=Earth+Magic+Oracle+Cards+-+Psychic+Bazaar&p=Earth+Magic+Oracle+Cards&oid=f0a5ad5c4211efe1c07515f56cf5a78e&fr2=piv-web&fr=mcafee&tt=Earth%2BMagic%2BOracle%2BCards%2B-%2BPsychic%2BBazaar&b=0&ni=90&no=5&ts=&tab=organic&sigr=126n355ib&sigb=13hbudmkc&sigi=11ta8f0gd&.crumb=IZBOU1c0UHU"),Referer{"search","Yahoo! Images","Earth Magic Oracle Cards"}},
		{"PriceRunner search",Parse("http://www.pricerunner.co.uk/search?displayNoHitsMessage=1&q=wild+wisdom+of+the+faery+oracle"),Referer{"search","PriceRunner","wild wisdom of the faery oracle"}},
		{"Bing Images search",Parse("http://www.bing.com/images/search?q=psychic+oracle+cards&view=detail&id=D268EDDEA8D3BF20AF887E62AF41E8518FE96F08"),Referer{"search","Bing Images","psychic oracle cards"}},
		{"IXquick search",Parse("https://s3-us3.ixquick.com/do/search"),Referer{"search","IXquick",""}},
		{"AOL search",Parse("http://aolsearch.aol.co.uk/aol/search?s_chn=hp&enabled_terms=&s_it=aoluk-homePage50&q=pendulums"),Referer{"search","AOL","pendulums"}},
		{"Ask search",Parse("http://uk.search-results.com/web?qsrc=1&o=1921&l=dis&q=pendulums&dm=ctry&atb=sysid%3D406%3Aappid%3D113%3Auid%3D8f40f651e7b608b5%3Auc%3D1346336505%3Aqu%3Dpendulums%3Asrc%3Dcrt%3Ao%3D1921&locale=en_GB"),Referer{"search","Ask","pendulums"}},
		{"Mail.ru search",Parse("http://go.mail.ru/search?q=Gothic%20Tarot%20Cards&where=any&num=10&rch=e&sf=20"),Referer{"search","Mail.ru","Gothic Tarot Cards"}},
		{"Yandex search",Parse("http://images.yandex.ru/yandsearch?text=Blue%20Angel%20Oracle%20Blue%20Angel%20Oracle&noreask=1&pos=16&rpt=simage&lr=45&img_url=http%3A%2F%2Fmdm.pbzstatic.com%2Foracles%2Fblue-angel-oracle%2Fbox-small.png"),Referer{"search","Yandex Images","Blue Angel Oracle Blue Angel Oracle"}},
		{"Twitter redirect",Parse("http://t.co/chrgFZDb"),Referer{"social","Twitter",""}},
		{"Facebook social",Parse("http://www.facebook.com/l.php?u=http%3A%2F%2Fwww.psychicbazaar.com&h=yAQHZtXxS&s=1"),Referer{"social","Facebook",""}},
		{"Facebook mobile",Parse("http://m.facebook.com/l.php?u=http%3A%2F%2Fwww.psychicbazaar.com%2Fblog%2F2012%2F09%2Fpsychic-bazaar-reviews-tarot-foundations-31-days-to-read-tarot-with-confidence%2F&h=kAQGXKbf9&s=1"),Referer{"social","Facebook",""}},
		{"Odnoklassniki",Parse("http://www.odnoklassniki.ru/dk?cmd=logExternal&st._aid=Conversations_Openlink&st.name=externalLinkRedirect&st.link=http%3A%2F%2Fwww.psychicbazaar.com%2Foracles%2F187-blue-angel-oracle.html"),Referer{"social","Odnoklassniki",""}},
		{"Tumblr social #1",Parse("http://www.tumblr.com/dashboard"),Referer{"social","Tumblr",""}},
		{"Tumblr w subdomain",Parse("http://psychicbazaar.tumblr.com/"),Referer{"social","Tumblr",""}},
		{"Yahoo, Mail",Parse("http://36ohk6dgmcd1n-c.c.yom.mail.yahoo.net/om/api/1.0/openmail.app.invoke/36ohk6dgmcd1n/11/1.0.35/us/en-US/view.html/0"),Referer{"email","Yahoo! Mail",""}},
		{"Outlook.com mail",Parse("http://co106w.col106.mail.live.com/default.aspx?rru=inbox"),Referer{"email","Outlook.com",""}},
		{"Orange Webmail",Parse("http://webmail1m.orange.fr/webmail/fr_FR/read.html?FOLDER=SF_INBOX&IDMSG=8594&check=&SORTBY=31"),Referer{"email","Orange Webmail",""}},
		{"Internal HTTP",Parse("http://www.snowplowanalytics.com/about/team"),Referer{"internal","",""}},
		{"Internal HTTPS",Parse("https://www.snowplowanalytics.com/account/profile"),Referer{"internal","",""}}}

  // Unknown referer URI
	e2 = []testUrl{
		{"Unknown referer #1",Parse("http://www.behance.net/gallery/psychicbazaarcom/2243272"),Referer{"unknown","",""}},
		{"Unknown referer #2",Parse("http://www.wishwall.me/home"),Referer{"unknown","",""}},
		{"Unknown referer #3",Parse("http://www.spyfu.com/domain.aspx?d=3897225171967988459"),Referer{"unknown","",""}},
		{"Unknown referer #4",Parse("http://seaqueen.wordpress.com/"),Referer{"unknown","",""}},
		{"Non-search Yahoo! site",Parse("http://finance.yahoo.com"),Referer{"unknown","Yahoo!",""}}}

  // Unavoidable false positives
  e3 = []testUrl{
		{"Unknown Google service",Parse("http://xxx.google.com"),Referer{"search","Google",""}},
		{"Unknown Yahoo! service",Parse("http://yyy.yahoo.com"),Referer{"search","Yahoo!",""}},
		{"Non-search Google Drive link",Parse("http://www.google.com/url?q=http://www.whatismyreferer.com/&sa=D&usg=ALhdy2_qs3arPmg7E_e2aBkj6K0gHLa5rQ"),Referer{"search","Google","http://www.whatismyreferer.com/"}}}
)

func TestGet(t *testing.T) {
	for _, test := range e1 {
		found_req, err := Get(test.Url)
		if !test.Ref.Equal(&found_req) ||  err != nil{
			t.Errorf("%s\nexpected: %#v =>\ngot: %#v\n",test.Name,test.Ref,found_req)
		}
	}
}
