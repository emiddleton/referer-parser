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

require 'yaml'

# This module processes the referers.yml file and
# uses it to create a global hash that is used to
# lookup URLs to see if they are known referers
# (e.g. search engines)
module RefererParser
  module Referers

    # Returns the referer indicated by
    # the given `uri`
    def self.get_referer(uri)
      # Check if domain+path matches (e.g. google.co.uk/products)
      refl = lookup_referer(uri.host, uri.path, true)
      if refl.nil?
        # Check if domain only matches (e.g. google.co.uk)
        refl = lookup_referer(uri.host, uri.path, false)
      end
      if refl.nil?
        return RefererParser::Referer.new(uri, "unknown")
      else
        if refl["medium"] == "search" and !uri.query.nil?
          return RefererParser::Referer.new(uri, "search", refl["source"], extract_search(uri.query, refl["parameters"]))
        end
        return RefererParser::Referer.new(uri, refl["medium"], refl["source"])
      end
    end

    def self.lookup_referer(host,path,include_path=true)
      #puts "lookup host=>#{host}, path=>#{path}, include_path=>#{include_path}"
      refl =
        if include_path
          referers[host+path]
        else
          referers[host]
        end
      if include_path and refl.nil?
        path_elements = path.split("/")
        refl =
          if path_elements.length > 1
            referers[host+"/"+path_elements[1]]
          end
      end
      if refl.nil?
        idx = host.index('.')
        if idx.nil?
          return nil
        else
          return lookup_referer(host[(idx+1)..-1],path,include_path)
        end
      end
      return refl
    end

    def self.extract_search(queries, possiables)
      CGI.parse(queries).each do |key,value|
        return value.first if possiables.include?(key)
      end
    end

    private # -------------------------------------------------------------

    def self.referers
      @@referers ||= load_referers_from_yaml(get_yaml_file)
      @@referers
    end

    # Returns the path to the YAML
    # file of referers
    def self.get_yaml_file(referer_file = nil)
      if referer_file.nil?
        File.join(File.dirname(__FILE__), '..', '..', 'data', 'referers.yml')
      else
        referer_file
      end
    end

    # Initializes a hash of referers
    # from the supplied YAML file
    def self.load_referers_from_yaml(yaml_file)

      unless File.exist?(yaml_file) and File.file?(yaml_file)
        raise ReferersYamlNotFoundError, "Could not find referers YAML file at '#{yaml_file}'"
      end

      # Load referer data stored in YAML file
      begin
        referers_yaml = YAML.load_file(yaml_file)
      rescue error
        raise CorruptReferersYamlError.new("Could not parse referers YAML file '#{yaml_file}'", error)
      end

      refs = {}
      referers_yaml.each do |medium_name,medium|
        medium.each do |source_name,source|
          parameters = source["parameters"]
          refl = { "medium" => medium_name,
                   "source" => source_name }
          if medium_name == "search"
            if parameters.nil?
              raise "No parameters found for search referer '#{source_name}'"
            else
              refl["parameters"] = parameters
            end
          else
            unless parameters.nil?
              raise "Parameters not supported for non-search referer '#{source_name}'"
            end
          end
          domains = source["domains"]
          if domains.empty?
            raise "No domains found for referer '#{source_name}'"
          end
          domains.each do |domain|
            refs[domain] = refl
          end
        end
      end
      refs

    end

  end
end
