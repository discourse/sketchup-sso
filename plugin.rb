# name: discourse-sketchup-sso
# about: Sketchup SSO support
# version: 0.1
# authors: Sam Saffron

class SketchupAuthenticator < Auth::OpenIdAuthenticator

  def after_authenticate(auth_token)
    result = super(auth_token)
    #info = auth_token[:info]

    # For now lets debug the info in /logs, we can remove later
    # Rails.logger.warn("OpenID reply recieved" << info.inspect)

    if result.email.present? && result.user.present?
      result.user.update_columns(email: result.email)
    end

    result
  end

end

url = Rails.env.development? ? 'https://dev-accounts.sketchup.com/openid/provider' :
                               'https://accounts.sketchup.com/openid/provider'

auth_provider :title => 'with SketchUp',
              :authenticator => SketchupAuthenticator.new(
                'sketchup', url,
                trusted: true),
              :message => 'Authenticating with Sketchup (make sure pop up blockers are not enabled)',
              :frame_width => 1000,   # the frame size used for the pop up window, overrides default
              :frame_height => 800


register_css <<CSS
.btn-social.sketchup {
  background: #e72b2d;
  background-repeat: no-repeat;
  background-position: 30px 4px;
  background-size: 22px;
  padding-left: 30px;
  background-image: url(data:image/png;base64,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);

}

CSS
