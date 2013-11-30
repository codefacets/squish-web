module SquashHelper

  # Call as part of {#body_content} to generate a full-width
  # (sixteen-column) content area with a white background. Yields to render
  # content.
  def full_width_section(alt=false,&block)
    content_tag :div, class: "content-container#{alt ? '-alt' : ''}" do
      content_tag :div, class: 'container' do
        content_tag :div, class: 'row' do
          content_tag :div, capture(&block), class: 'sixteen columns'
        end
      end
    end
  end

  # Call as part of {#body_content} to generate a full-width
  # (sixteen-column) content area with a shaded background below a tabbed
  # header portion. The `tabs_proc` should render a `<UL>` with your tab
  # headers, and the `content_proc` should render the tab bodies. See
  # tabs.js.coffee for how to organize it.
  def tabbed_section(tabs_proc, content_proc)
    content_tag :div, class: 'tab-header-container' do
      content_tag :div, class: 'container' do
        content_tag :div, class: 'row' do
          content_tag :div, tabs_proc.(), class: 'sixteen columns'
         end
      end
    end
    content_tag :div, class: 'tab-container' do
      content_tag :div, class: 'container' do
        content_tag :div, class: 'row' do
          content_tag :div, content_proc.(), class: 'sixteen columns'
        end
      end
    end
  end

  def tab_header(&block)
    render 'squash/shared/tab_header', tab_header_content: capture(&block)
  end

  def tab_container(&block)
    render 'squash/shared/tab_container', tab_content: capture(&block)
  end

  # Call as part of {#body_content} to generate an inset, shaded
  # twelve-column content area simulating the appearance of a modal. Yields
  # to render content.
  def modal_section(&block)
    content_tag :div, class: 'content-container' do
      content_tag :div, class: 'container modal-container' do
        content_tag :div, class: 'row row-modal' do
          content_tag :div, '&nbsp;'.html_safe, class: 'two columns'
          content_tag :div, capture(&block), class: 'twelve columns'
          content_tag :div, '&nbsp;'.html_safe, class: 'two columns'
        end
      end
    end
  end

  def page_title
    @page_title
  end

  def breadcrumbs
    @breadcrumbs || []
  end

  def breadcrumbs_stats
    @breadcrumbs_stats || []
  end

  # def button_to(name, location, overrides={})
  #   button name, overrides.reverse_merge(href: location)
  # end

  def footer_portion
    footer do
      p { image_tag 'footer.png' }

      p do
        text "Hand-coded in San Francisco by Tim Morgan of "
        a "Square, Inc.", href: 'https://squareup.com'
      end
    end
  end

   # Composition of `pluralize` and `number_with_delimiter`.
  #
  # @param [Numeric] count The number of things.
  # @param [String] singular The name of the thing.
  # @param [String] plural The name of two of those things.
  # @return [String] Localized string describing the number and identity of the
  #   things.

  def pluralize_with_delimiter(count, singular, plural=nil)
    count ||= 0
    "#{number_with_delimiter count} " + ((count == 1 || count =~ /^1(\.0+)?$/) ? singular : (plural || singular.pluralize))
  end

  # Returns a link to a Project's commit (assuming the Project has a commit link
  # format specified). The title of the link will be the commit ID (abbreviated
  # if appropriate).
  #
  # If the commit URL cannot be determined, the full SHA1 is wrapped in a `CODE`
  # tag.
  #
  # @param [Project] project The project that the commit is to.
  # @param [String] commit The full ID of the commit.
  # @return [String] A link to the commit.

  def commit_link(project, commit)
    if url = project.commit_url(commit)
      link_to commit[0, 6], url
    else
      content_tag :tt, commit[0, 6]
    end
  end

  # Creates a link to open a project file in the user's editor. See the
  # editor_link.js.coffee file for more information.
  #
  # @param [String] editor The editor ("textmate", "sublime", "vim", or
  #   "emacs").
  # @param [Project] project The project containing the file.
  # @param [String] file The file path relative to the project root.
  # @param [String] line The line number within the file.

  def editor_link(editor, project, file, line)
    content_tag :a, '', :'data-editor' => editor, :'data-file' => file, :'data-line' => line, :'data-project' => project.to_param
  end

  # Converts a number in degrees decimal (DD) to degrees-minutes-seconds (DMS).
  #
  # @param [Float] coord The longitude or latitude, in degrees.
  # @param [:lat, :lon] axis The axis of the coordinate value.
  # @param [Hash] options Additional options.
  # @option options [Fixnum] :precision (2) The precision of the seconds value.
  # @return [String] Localized display of the DMS value.
  # @raise [ArgumentError] If an axis other than `:lat` or `:lon` is given.

  def number_to_dms(coord, axis, options={})
    positive = coord >= 0
    coord = coord.abs

    degrees = coord.floor
    remainder = coord - degrees
    minutes = (remainder*60).floor
    remainder -= minutes/60.0
    seconds = (remainder*60).round(options[:precision] || 2)

    hemisphere = case axis
                   when :lat
                     t("helpers.application.number_to_dms.#{positive ? 'north' : 'south'}")
                   when :lon
                     t("helpers.application.number_to_dms.#{positive ? 'east' : 'west'}")
                   else
                     raise ArgumentError, "axis must be :lat or :lon"
                 end

    t('helpers.application.number_to_dms.coordinate', degrees: degrees, minutes: minutes, seconds: seconds, hemisphere: hemisphere)
  end

  # Given the parts of a backtrace element, creates a single string displaying
  # them together in a typical backtrace format.
  #
  # @param [String] file The file path.
  # @param [Fixnum] line The line number in the file.
  # @param [String] method The method name.

  def format_backtrace_element(file, line, method=nil)
    str = "#{file}:#{line}"
    str << " (in `#{method}`)" if method
    str
  end

end
