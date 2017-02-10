require 'middleman-blog/uri_templates'

module Middleman
  module Blog
    # A sitemap resource manipulator that adds a tag page to the sitemap
    # for each tag in the associated blog
    class SectionPages
      include UriTemplates

      def initialize(app, blog_controller)
        @sitemap = app.sitemap
        @blog_controller = blog_controller
        @section_link_template = uri_template blog_controller.options.sectionlink
        @section_template = blog_controller.options.section_template
        @blog_data = blog_controller.data

        @generate_section_pages = blog_controller.options.generate_section_pages
      end

      # Get a path to the given tag, based on the :taglink setting.
      # @param [String] tag
      # @return [String]
      def link(section)
        apply_uri_template @section_link_template, section: safe_parameterize(section)
      end

      # Update the main sitemap resource list
      # @return [void]
      def manipulate_resource_list(resources)
        return resources unless @generate_section_pages

        resources + @blog_data.sections.map do |section, articles|
          section_page_resource(section, articles)
        end
      end

      private

      def section_page_resource(tag, articles)
        Sitemap::ProxyResource.new(@sitemap, link(section), @section_template).tap do |p|
          # Add metadata in local variables so it's accessible to
          # later extensions
          p.add_metadata locals: {
            'page_type' => 'section',
            'sectionname' => section,
            'articles' => articles,
            'blog_controller' => @blog_controller
          }
        end
      end
    end
  end
end
