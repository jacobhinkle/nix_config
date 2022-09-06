{
  enable = true;
  extraConfig = ''
    config.pdfjs = True
    c.colors.webpage.preferred_color_scheme = 'dark'

    # Redirect to old.reddit.com
    # from: https://www.reddit.com/r/qutebrowser/comments/n90y93/a_simple_script_to_convert_reddit_links_to/
    import qutebrowser.api.interceptor

    def rewrite(request: qutebrowser.api.interceptor.Request):
      if request.request_url.host() == 'www.reddit.com':
          request.request_url.setHost('old.reddit.com')
          try:
              request.redirect(request.request_url)
          except:
              pass

    qutebrowser.api.interceptor.register(rewrite)
  '';
  keyBindings = {
    normal = {
      "<Shift-J>" = "tab-prev";
      "<Shift-K>" = "tab-next";
    };
  };
}
