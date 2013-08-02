package referer

import (
	"flag"
	"strings"
	"log"
//	"fmt"
	"net/url"
	"github.com/kylelemons/go-gypsy/yaml"
)

type RefererLookup struct {
	Medium     string
	Source     string
	Parameters []string
}

type Referers map[string]RefererLookup

type Referer struct {
	Medium     string
	Source     string
	Term       string
}

var (
	referers_yml_file = flag.String("referers_yml", "referers.yml", "Referer parser data")
	referers = Referers{}
)

func (ref1 Referer) Equal(ref2 *Referer) (equal bool){
	return (ref1.Medium == ref2.Medium && ref1.Source == ref2.Source && ref1.Term == ref2.Term)
}

func Get(uri *url.URL) (ref Referer, err error) {

	refl, found := lookupReferer(uri.Host, uri.Path, true)
	if !found {
		refl, found = lookupReferer(uri.Host, uri.Path, false)
	}

	if !found {
		return Referer{Medium:"unknown"}, nil
	} else {
		if refl.Medium == "search" {
			term, _ := extractSearchTerm(uri, refl.Parameters)
			return Referer{Medium:"search", Source:refl.Source, Term:term}, nil
		}
		return Referer{Medium:refl.Medium, Source: refl.Source}, err
	}
}

func lookupReferer(host string, path string, include_path bool) (refl RefererLookup, found bool) {

	ok := false

	if include_path {
		refl, ok = referers[host+path]
	} else {
		refl, ok = referers[host]
	}

	if include_path && !ok {
		path_elements := strings.Split(path,"/")
		if len(path_elements) > 1 {
			refl, ok = referers[host+"/"+path_elements[1]]
		}
	}

	if !ok {
		idx := strings.Index(host,".")
		if idx == -1 {
			return refl, false //panic("Referer not found")
		} else {
			return lookupReferer(host[(idx+1):],path,include_path)
		}
	}
	return refl, ok
}

func extractSearchTerm(url *url.URL, possiables []string) (term string, ok bool) {
	for name, value := range url.Query() {
		for _, possiable := range possiables {
			if name == possiable {
				return value[0], true;
			}
		}
	}
	return term, false;
}

func init() {

	referers_yml,err := yaml.ReadFile(*referers_yml_file)
	if err != nil {
		log.Fatalf("readfile(%q): %s", *referers_yml_file, err)
	}
	m,e := referers_yml.Root.(yaml.Map)
	if !e {
		log.Fatalf("Root(%q): %s", *referers_yml_file, err)
	}

	for medium, medium_map := range m {
		for source, source_node := range medium_map.(yaml.Map) {

			parameters := []string{}

			terms_node := source_node.(yaml.Map).Key("parameters")
			if terms_node != nil {
				for _, term_node := range terms_node.(yaml.List) {
					parameters = append(parameters, term_node.(yaml.Scalar).String())
				}
			}

			// Validate
			if medium == "search" {
				if terms_node == nil {
					panic("No parameters found for search referer '" + source + "'")
				}
			} else {
				if terms_node != nil {
					panic("Parameters not supported for non-search referer '" + source + "'")
				}
			}
			domains_node := source_node.(yaml.Map).Key("domains")
			if domains_node == nil {
				panic("No domains found for referer '" + source + "'")
			}

			referer := RefererLookup{Medium:medium, Source:source, Parameters:parameters}

			for _, domain_node := range domains_node.(yaml.List) {
				domain := domain_node.(yaml.Scalar).String()
				_, ok := referers[domain]
				if !ok {
				//	panic("Duplicate of domain '" + domain + "' found")
				//} else {
					referers[domain] = referer
				}
			}
		}
  }
	//fmt.Printf("%#v\n",referers)
	/*
	referer_url,_ := url.Parse("https://www.google.co.il/aclk?q=test")
  val, err      := Get(referer_url)
  if err != nil {
    log.Fatalf("Get(%q): %s", *file, err)
  }
  fmt.Printf("%#v => %#v",referer_url,val)
	*/
}
