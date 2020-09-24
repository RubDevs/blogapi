module Secured 
    def authenticate_user!
        #Bearer xxxxx
        token_regex = /Bearer (\w+)/
        #Leer Header de auth
        headers = request.headers
        #Verificar que sea valido
        if headers['Authorization'].present? && headers['Authorization'].match(token_regex)
            token = headers['Authorization'].match(token_regex)[1]

            if (Current.user = User.find_by_auth_token(token))
                return
            end
        end
        render json: { error: 'Unauthorized' }, status: :unauthorized
    end
end