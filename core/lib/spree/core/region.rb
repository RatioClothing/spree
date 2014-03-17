module Spree
  module Core
    module Region
      extend ActiveSupport::Concern

      included do
        validate :valid_country_code
        validate :valid_region_code

        def country_code=(country_code)
          country = Carmen::Country.coded(country_code)

          #proper case and switch 3 digit to 2 digit if it matches, etc
          write_attribute(:country_code, country.try(:code) || country_code)
          lookup_region_code(region_text) unless region_text.blank?
        end

        def country_text
          country.try(:name)
        end

        def country_text=(country_text)
          country = Carmen::Country.coded(country_text) || Carmen::Country.named(country_text)
          write_attribute :country_code, country.try(:code)
        end

        def valid_country_code
          errors.add(:country_code, :invalid_country) if country.nil? && !country_code.blank?
        end

        def valid_region_code
          errors.add(:region_code, :invalid_region) if region.nil? && !region_code.blank?
        end

        def country
          Carmen::Country.coded(country_code)
        end

        def lookup_region_code(region_text)
          unless country.nil? || region_text.blank?
            region = country.subregions.coded(region_text) || country.subregions.named(region_text)
            write_attribute(:region_code, region.try(:code))
          end
        end

        def region
          country.subregions.coded(region_code) unless country.nil? || region_code.blank?
        end

        def region_text=(region_text)
          lookup_region_code(region_text)
          write_attribute(:region_text, region_text)
        end

        def region_code=(region_code)
          write_attribute(:region_code, region_code)
          write_attribute(:region_text, region_code)
        end
      end
    end
  end
end
