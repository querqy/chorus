# frozen_string_literal: true
class CatalogController < ApplicationController

  include Blacklight::Catalog

  configure_blacklight do |config|
    config.view.gallery.partials = [:index_header, :index]
    config.view.masonry.partials = [:index]
    config.view.slideshow.partials = [:index]
    # Set the gallery view to have four columns instead of three.
    config.view.gallery.classes = 'row-cols-3 row-cols-md-4'


    config.show.tile_source_field = :content_metadata_image_iiif_info_ssm
    config.show.partials.insert(1, :openseadragon)
    ## Class for sending and receiving requests from a search index
    # config.repository_class = Blacklight::Solr::Repository
    #
    ## Class for converting Blacklight's url parameters to into request parameters for the search index
    # config.search_builder_class = ::SearchBuilder
    #
    ## Model that maps search index responses to the blacklight response model
    # config.response_model = Blacklight::Solr::Response
    #
    ## Should the raw solr document endpoint (e.g. /catalog/:id/raw) be enabled
    # config.raw_endpoint.enabled = false

    ## Default parameters to send to solr for all search-like requests. See also SearchBuilder#processed_parameters
    config.default_solr_params = {
      q:"*:*",
      rows: 30,
      'facet.mincount':1,
      'facet.limit':10
    }

    # solr path which will be added to solr base url before the other solr params.
    #config.solr_path = 'select'
    #config.document_solr_path = 'get'

    # items to show per page, each number in the array represent another option to choose from.
    config.per_page = [30,50,100]

    # solr field configuration for search results/index views
    config.index.title_field = 'title' #'title_tsim'
    #config.index.display_type_field = 'format'
    #config.index.thumbnail_field = 'thumbnail_path_ss'
    config.index.thumbnail_field = 'img_500x500'

    config.add_results_document_tool(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)

    config.add_results_collection_tool(:sort_widget)
    config.add_results_collection_tool(:per_page_widget)
    config.add_results_collection_tool(:view_type_group)

    config.add_show_tools_partial(:bookmark, partial: 'bookmark_control', if: :render_bookmarks_control?)
    #config.add_show_tools_partial(:email, callback: :email_action, validator: :validate_email_params)
    #config.add_show_tools_partial(:sms, if: :render_sms_action?, callback: :sms_action, validator: :validate_sms_params)
    #config.add_show_tools_partial(:citation)

    config.add_nav_action(:bookmark, partial: 'blacklight/nav/bookmark', if: :render_bookmarks_control?)
    config.add_nav_action(:search_history, partial: 'blacklight/nav/search_history')

    # solr field configuration for document/show views
    #config.show.title_field = 'title_tsim'
    config.show.title_field = 'title'
    #config.show.display_type_field = 'format'
    #config.show.thumbnail_field = 'thumbnail_path_ss'
    config.show.thumbnail_field = 'img_500x500'

    # solr fields that will be treated as facets by the blacklight application
    #   The ordering of the field names is the order of the display
    #
    # Setting a limit will trigger Blacklight's 'more' facet values link.
    # * If left unset, then all facet values returned by solr will be displayed.
    # * If set to an integer, then "f.somefield.facet.limit" will be added to
    # solr request, with actual solr request being +1 your configured limit --
    # you configure the number of items you actually want _displayed_ in a page.
    # * If set to 'true', then no additional parameters will be sent to solr,
    # but any 'sniffed' request limit parameters will be used for paging, with
    # paging at requested limit -1. Can sniff from facet.limit or
    # f.specific_field.facet.limit solr request params. This 'true' config
    # can be used if you set limits in :default_solr_params, or as defaults
    # on the solr side in the request handler itself. Request handler defaults
    # sniffing requires solr requests to be made with "echoParams=all", for
    # app code to actually have it echo'd back to see it.
    #
    # :show may be set to false if you don't want the facet to be drawn in the
    # facet bar
    #
    # set :index_range to true if you want the facet pagination view to have facet prefix-based navigation
    #  (useful when user clicks "more" on a large facet and wants to navigate alphabetically across a large set of results)
    # :index_range can be an array or range of prefixes that will be used to create the navigation (note: It is case sensitive when searching values)

    #config.add_facet_field 'format', label: 'Format'
    #config.add_facet_field 'pub_date_ssim', label: 'Publication Year', single: true
    #config.add_facet_field 'subject_ssim', label: 'Topic', limit: 20, index_range: 'A'..'Z'
    #config.add_facet_field 'language_ssim', label: 'Language', limit: true
    #config.add_facet_field 'lc_1letter_ssim', label: 'Call Number'
    #config.add_facet_field 'subject_geo_ssim', label: 'Region'
    #config.add_facet_field 'subject_era_ssim', label: 'Era'
    config.add_facet_field 'filter_brand', label: 'Brands', limit: 20
    config.add_facet_field 'filter_product_type', label: 'Product Type', limit: 20
    config.add_facet_field 'filter_t_product_colour', label: 'Product Colour', limit: 20
    #config.add_facet_field 'filter_t_colour_name', label: 'Colour Name', limit: 20

    config.add_facet_field 'example_pivot_field', label: 'Categories', :pivot => ['filter_product_type', 'filter_brand'], limit: 5

    config.add_facet_field 'example_query_facet_field', label: 'Released', :query => {
       :years_5 => { label: 'within 5 Years', fq: "date_released:[NOW-5YEAR/DAY TO NOW]" },
       :years_10 => { label: 'within 10 Years', fq: "date_released:[NOW-10YEAR/DAY TO NOW]" },
       :years_25 => { label: 'within 25 Years', fq: "date_released:[NOW-25YEAR/DAY TO NOW]" }
    }



    # Have BL send all facet field names to Solr, which has been the default
    # previously. Simply remove these lines if you'd rather use Solr request
    # handler defaults, or have no facets.
    config.add_facet_fields_to_solr_request!

    # solr fields to be displayed in the index (search results) view
    #   The ordering of the field names is the order of the display
    #config.add_index_field 'title', label: 'Product'
    #config.add_index_field 'title_vern_ssim', label: 'Title'
    #config.add_index_field 'author_tsim', label: 'Author'
    #config.add_index_field 'author_vern_ssim', label: 'Author'
    #config.add_index_field 'format', label: 'Format'
    #config.add_index_field 'language_ssim', label: 'Language'
    #config.add_index_field 'published_ssim', label: 'Published'
    #config.add_index_field 'published_vern_ssim', label: 'Published'
    #config.add_index_field 'lc_callnum_ssim', label: 'Call number'
    config.add_index_field 'brand', label: 'Brand', link_to_facet: :filter_brand
    config.add_index_field 'date_released', label: 'Date', helper_method: 'prettify_date'
    config.add_index_field 'price', label: 'Price', helper_method: 'prettify_price'


    # solr fields to be displayed in the show (single result) view
    #   The ordering of the field names is the order of the display
    #config.add_show_field 'title', label: 'Title'
    config.add_show_field 'brand', label: 'Brand'
    config.add_show_field 'product_type', label: 'Product Type'
    config.add_show_field 'short_description', label: 'Short Desc'
    config.add_show_field 'ean', label: 'EAN'
    config.add_show_field 'date_released', label: 'Released', helper_method: 'prettify_date'
    config.add_show_field 'price', label: 'Price', helper_method: 'prettify_price'

    config.add_show_field 'search_attributes', label: 'Searchable Attributes'
    #config.add_show_field 'subtitle_vern_ssim', label: 'Subtitle'
    #config.add_show_field 'author_tsim', label: 'Author'
    #config.add_show_field 'author_vern_ssim', label: 'Author'
    #config.add_show_field 'format', label: 'Format'
    #config.add_show_field 'url_fulltext_ssim', label: 'URL'
    #config.add_show_field 'url_suppl_ssim', label: 'More Information'
    #config.add_show_field 'language_ssim', label: 'Language'
    #config.add_show_field 'published_ssim', label: 'Published'
    #config.add_show_field 'published_vern_ssim', label: 'Published'
    #config.add_show_field 'lc_callnum_ssim', label: 'Call number'
    #config.add_show_field 'isbn_ssim', label: 'ISBN'

    # "fielded" search configuration. Used by pulldown among other places.
    # For supported keys in hash, see rdoc for Blacklight::SearchFields
    #
    # Search fields will inherit the :qt solr request handler from
    # config[:default_solr_parameters], OR can specify a different one
    # with a :qt key/value. Below examples inherit, except for subject
    # that specifies the same :qt as default for our own internal
    # testing purposes.
    #
    # The :key is what will be used to identify this BL search field internally,
    # as well as in URLs -- so changing it after deployment may break bookmarked
    # urls.  A display label will be automatically calculated from the :key,
    # or can be specified manually to be different.

    # This one uses all the defaults set by the solr request handler. Which
    # solr request handler? The one set in config[:default_solr_parameters][:qt],
    # since we aren't specifying it otherwise.

    # The RIGHT way is the field.solr_path, but currently isn't supported by Blacklight
    # to have the solr_path set at a field level, only at the config.solr_path.
    # So instead, we are going to use the legacy qt= parameter.

    # Actually, the right way is the useParams parameter ;-)
    config.add_search_field 'default', label: 'Default Algo' do |field|
      #field.solr_path = 'select'
    end

    config.add_search_field('mustmatchall', label: 'Must Match All') do |field|
      field.qt = 'mustmatchall'
    end

    config.add_search_field('querqy', label: 'Querqy Algo') do |field|
      field.qt = 'querqy'
    end

    #config.add_search_field('title') do |field|
      # solr_parameters hash are sent to Solr as ordinary url query params.
    #  field.solr_parameters = {
    #    'spellcheck.dictionary': 'title',
    #    qf: '${title_qf}',
    #    pf: '${title_pf}'
    #  }
    #end

    #config.add_search_field('author') do |field|
    #  field.solr_parameters = {
    #    'spellcheck.dictionary': 'author',
    #    qf: '${author_qf}',
    #    pf: '${author_pf}'
    #  }
    #end

    # Specifying a :qt only to show it's possible, and so our internal automated
    # tests can test it. In this case it's the same as
    # config[:default_solr_parameters][:qt], so isn't actually neccesary.
    #config.add_search_field('subject') do |field|
    #  field.qt = 'search'
    #  field.solr_parameters = {
    #    'spellcheck.dictionary': 'subject',
    #    qf: '${subject_qf}',
    #  }
    #end

    # "sort results by" select (pulldown)
    # label in pulldown is followed by the name of the SOLR field to sort by and
    # whether the sort is ascending or descending (it must be asc or desc
    # except in the relevancy case).
    config.add_sort_field 'score desc', label: 'relevance'
    config.add_sort_field 'date_released desc', label: 'released'
    #config.add_sort_field 'author_si asc, title_si asc', label: 'author'
    #config.add_sort_field 'title_si asc, pub_date_si desc', label: 'title'

    # If there are more than this many search results, no spelling ("did you
    # mean") suggestion is offered.
    config.spell_max = 5

    # Configuration for autocomplete suggestor
    config.autocomplete_enabled = true
    config.autocomplete_path = 'suggest'
    # if the name of the solr.SuggestComponent provided in your solrcongig.xml is not the
    # default 'mySuggester', uncomment and provide it below
    # config.autocomplete_suggester = 'mySuggester'
  end
end
