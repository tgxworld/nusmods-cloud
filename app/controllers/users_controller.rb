class UsersController < ApplicationController
  before_filter :authenticate_user_from_token!, only: [:show, :update]

  def auth
    profile = IVLE.new(auth_params[:ivleToken]).get_profile
    unless profile.present? && profile[:nusnet_id].casecmp(auth_params[:nusnetId]) == 0
      return generate_error_payload(401, 'Your token is not my token.')
    end

    user = User.find_by_nusnet_id(profile[:nusnet_id]) || User.new
    user.assign_attributes(profile)
    user.access_token = Digest::SHA2.base64digest(profile[:ivle_token])
    user.save

    render json: user, serializer: UserProfileSerializer
  end

  private
    def auth_params
      params.require(:nusnetId)
      params.require(:ivleToken)
      params.permit(:nusnetId, :ivleToken)
    end
end