# frozen_string_literal: true

module Blacklight
  module Response
    # Render a pagination widget for search results
    class PaginationComponent < ::ViewComponent::Base
      # @param [Blacklight::Response] response
      # @param [Hash] html html options for the pagination container
      def initialize(response:, html: {}, **pagination_args)
        @response = response
        @html_attr = { aria: { label: t('views.pagination.aria.container_label') } }.merge(html)
        @pagination_args = { outer_window: 2, theme: 'blacklight' }.merge(pagination_args)

        # Look up any Querqy Decorations that might be returned, and if there is one then
        # pass it to the front end HTML layer.  Today Querqy only has a single decoration pattern called REDIRECT.
        querqy_decorations = @response['querqy_decorations']
        if querqy_decorations
          @redirect_url = querqy_decorations[0].delete_prefix("REDIRECT")
        end
      end

      def pagination
        @view_context.paginate @response, **@pagination_args
      end
    end
  end
end
