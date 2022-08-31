{
  enable = true;
  domain = "git.jhink.org";
  rootUrl = "https://git.jhink.org";
  lfs = {
    enable = true;
    contentDir = "/serverdata/gitea/lfs_content";
  };
  stateDir = "/serverdata/gitea";
  settings = {
    repository = {
      DEFAULT_BRANCH = "main";
    };
  };
}
