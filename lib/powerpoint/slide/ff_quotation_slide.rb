require 'zip/filesystem'
require 'fileutils'
require 'fastimage'
require 'erb'
require 'mimemagic'

module Powerpoint
  module Slide
    class FFQuotationSlide
      include Powerpoint::Util

      DEFAULT_IMAGE_PATH = File.expand_path('../../../templates/collision-2025-template/ppt/media/default-quote.png', __dir__)

      attr_reader :title, :subtitle, :content, :icon_image_path, :attribution_image_path, :attribution, :links

      def initialize(options = {})
        require_arguments [:presentation, :content], options
        options.each { |k, v| instance_variable_set("@#{k}", v) }

        @icon_image_path = DEFAULT_IMAGE_PATH if @icon_image_path.to_s.strip.empty?
        @icon_image_name = File.basename(@icon_image_path)
        @images = { @icon_image_name => @icon_image_path }

        unless @attribution_image_path.to_s.strip.empty?
          @attribution_image_name = File.basename(@attribution_image_path)
          @images[@attribution_image_name] = @attribution_image_path
        end
      end

      def file_type
        @images.map{ |image_name, image_path| { type: MimeMagic.by_magic(File.open(image_path)).type, path: "/ppt/media/#{image_name.gsub('jpg','jpeg')}" } }
      end

      def save(extract_path, index)
        @images.each do |image_name, image_path|
          copy_media(extract_path, image_path) if image_path != nil
        end
        save_rel_xml(extract_path, index)
        save_slide_xml(extract_path, index)
      end

      def save_rel_xml(extract_path, index)
        render_view('ff_quotation_slide_rel.xml.erb', "#{extract_path}/ppt/slides/_rels/slide#{index}.xml.rels")
      end
      private :save_rel_xml

      def save_slide_xml(extract_path, index)
        render_view('ff_quotation_slide.xml.erb', "#{extract_path}/ppt/slides/slide#{index}.xml")
      end
      private :save_slide_xml
    end
  end
end