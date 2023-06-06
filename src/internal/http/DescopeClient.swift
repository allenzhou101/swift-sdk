
import Foundation

class DescopeClient: HTTPClient {
    let config: DescopeConfig
    
    init(config: DescopeConfig, session: URLSession? = nil) {
        self.config = config
        super.init(baseURL: config.baseURL, session: session)
    }
    
    // MARK: - OTP
    
    func otpSignUp(with method: DeliveryMethod, loginId: String, details: SignUpDetails?) async throws -> MaskedAddress {
        return try await post("otp/signup/\(method.rawValue)", body: [
            "loginId": loginId,
            "user": details?.dictValue,
        ])
    }
    
    func otpSignIn(with method: DeliveryMethod, loginId: String) async throws -> MaskedAddress {
        return try await post("otp/signin/\(method.rawValue)", body: [
            "loginId": loginId
        ])
    }
    
    func otpSignUpIn(with method: DeliveryMethod, loginId: String) async throws -> MaskedAddress {
        return try await post("otp/signup-in/\(method.rawValue)", body: [
            "loginId": loginId
        ])
    }
    
    func otpVerify(with method: DeliveryMethod, loginId: String, code: String) async throws -> JWTResponse {
        return try await post("otp/verify/\(method.rawValue)", body: [
            "loginId": loginId,
            "code": code,
        ])
    }
    
    func otpUpdateEmail(_ email: String, loginId: String, refreshJwt: String, options: UpdateOptions) async throws -> MaskedAddress {
        return try await post("otp/update/email", headers: authorization(with: refreshJwt), body: [
            "loginId": loginId,
            "email": email,
            "addToLoginIDs": options.contains(.addToLoginIds),
            "onMergeUseExisting": options.contains(.onMergeUseExisting),
        ])
    }
    
    func otpUpdatePhone(_ phone: String, with method: DeliveryMethod, loginId: String, refreshJwt: String, options: UpdateOptions) async throws -> MaskedAddress {
        try method.ensurePhoneMethod()
        return try await post("otp/update/phone/\(method.rawValue)", headers: authorization(with: refreshJwt), body: [
            "loginId": loginId,
            "phone": phone,
            "addToLoginIDs": options.contains(.addToLoginIds),
            "onMergeUseExisting": options.contains(.onMergeUseExisting),
        ])
    }
    
    // MARK: - TOTP
    
    struct TOTPResponse: JSONResponse {
        var provisioningURL: String
        var image: String
        var key: String
    }
    
    func totpSignUp(loginId: String, details: SignUpDetails?) async throws -> TOTPResponse {
        return try await post("totp/signup", body: [
            "loginId": loginId,
            "user": details?.dictValue,
        ])
    }
    
    func totpVerify(loginId: String, code: String) async throws -> JWTResponse {
        return try await post("totp/verify", body: [
            "loginId": loginId,
            "code": code,
        ])
    }
    
    func totpUpdate(loginId: String, refreshJwt: String) async throws -> TOTPResponse {
        return try await post("totp/update", headers: authorization(with: refreshJwt), body: [
            "loginId": loginId,
        ])
    }
    
    // MARK: - Password
    
    func passwordSignUp(loginId: String, password: String, details: SignUpDetails?) async throws -> JWTResponse {
        return try await post("password/signup", body: [
            "loginId": loginId,
            "user": details?.dictValue,
            "password": password,
        ])
    }
    
    func passwordSignIn(loginId: String, password: String) async throws -> JWTResponse {
        return try await post("password/signin", body: [
            "loginId": loginId,
            "password": password,
        ])
    }
    
    func passwordUpdate(loginId: String, newPassword: String, refreshJwt: String) async throws {
        try await post("password/update", headers: authorization(with: refreshJwt), body: [
            "loginId": loginId,
            "newPassword": newPassword,
        ])
    }
    
    func passwordReplace(loginId: String, oldPassword: String, newPassword: String) async throws {
        try await post("password/replace", body: [
            "loginId": loginId,
            "oldPassword": oldPassword,
            "newPassword": newPassword,
        ])
    }
    
    func passwordSendReset(loginId: String, redirectURL: String?) async throws {
        try await post("password/reset", body: [
            "loginId": loginId,
            "redirectUrl": redirectURL,
        ])
    }
    
    struct PasswordPolicyResponse: JSONResponse {
        var minLength: Int
        var lowercase: Bool
        var uppercase: Bool
        var number: Bool
        var nonAlphanumeric: Bool
    }
    
    func passwordGetPolicy() async throws -> PasswordPolicyResponse {
        return try await get("password/policy")
    }

    
    // MARK: - Magic Link
    
    func magicLinkSignUp(with method: DeliveryMethod, loginId: String, details: SignUpDetails?, uri: String?) async throws -> MaskedAddress {
        return try await post("magiclink/signup/\(method.rawValue)", body: [
            "loginId": loginId,
            "user": details?.dictValue,
            "uri": uri,
        ])
    }
    
    func magicLinkSignIn(with method: DeliveryMethod, loginId: String, uri: String?) async throws -> MaskedAddress {
        return try await post("magiclink/signin/\(method.rawValue)", body: [
            "loginId": loginId,
            "uri": uri,
        ])
    }
    
    func magicLinkSignUpOrIn(with method: DeliveryMethod, loginId: String, uri: String?) async throws -> MaskedAddress {
        return try await post("magiclink/signup-in/\(method.rawValue)", body: [
            "loginId": loginId,
            "uri": uri,
        ])
    }
    
    func magicLinkVerify(token: String) async throws -> JWTResponse {
        return try await post("magiclink/verify", body: [
            "token": token,
        ])
    }
    
    func magicLinkUpdateEmail(_ email: String, loginId: String, uri: String?, refreshJwt: String, options: UpdateOptions) async throws -> MaskedAddress {
        return try await post("magiclink/update/email", headers: authorization(with: refreshJwt), body: [
            "loginId": loginId,
            "email": email,
            "uri": uri,
            "addToLoginIDs": options.contains(.addToLoginIds),
            "onMergeUseExisting": options.contains(.onMergeUseExisting),
        ])
    }
    
    func magicLinkUpdatePhone(_ phone: String, with method: DeliveryMethod, loginId: String, uri: String?, refreshJwt: String, options: UpdateOptions) async throws -> MaskedAddress {
        try method.ensurePhoneMethod()
        return try await post("magiclink/update/phone/\(method.rawValue)", headers: authorization(with: refreshJwt), body: [
            "loginId": loginId,
            "phone": phone,
            "uri": uri,
            "addToLoginIDs": options.contains(.addToLoginIds),
            "onMergeUseExisting": options.contains(.onMergeUseExisting),
        ])
    }
    
    // MARK: - Enchanted Link
    
    struct EnchantedLinkResponse: JSONResponse {
        var linkId: String
        var pendingRef: String
        var maskedEmail: String
    }
    
    func enchantedLinkSignUp(loginId: String, details: SignUpDetails?, uri: String?) async throws -> EnchantedLinkResponse {
        return try await post("enchantedlink/signup/email", body: [
            "loginId": loginId,
            "user": details?.dictValue,
            "uri": uri,
        ])
    }
    
    func enchantedLinkSignIn(loginId: String, uri: String?) async throws -> EnchantedLinkResponse {
        try await post("enchantedlink/signin/email", body: [
            "loginId": loginId,
            "uri": uri,
        ])
    }
    
    func enchantedLinkSignUpOrIn(loginId: String, uri: String?) async throws -> EnchantedLinkResponse {
        try await post("enchantedlink/signup-in/email", body: [
            "loginId": loginId,
            "uri": uri,
        ])
    }
    
    func enchantedLinkUpdateEmail(_ email: String, loginId: String, uri: String?, refreshJwt: String, options: UpdateOptions) async throws -> EnchantedLinkResponse {
        return try await post("enchantedlink/update/email", headers: authorization(with: refreshJwt), body: [
            "loginId": loginId,
            "email": email,
            "uri": uri,
            "addToLoginIDs": options.contains(.addToLoginIds),
            "onMergeUseExisting": options.contains(.onMergeUseExisting),
        ])
    }
    
    func enchantedLinkPendingSession(pendingRef: String) async throws -> JWTResponse {
        return try await post("enchantedlink/pending-session", body: [
            "pendingRef": pendingRef,
        ])
    }
    
    // MARK: - OAuth
    
    struct OAuthResponse: JSONResponse {
        var url: String
    }
    
    func oauthStart(provider: OAuthProvider, redirectURL: String?) async throws -> OAuthResponse {
        return try await post("oauth/authorize", params: [
            "provider": provider.rawValue,
            "redirectURL": redirectURL,
        ])
    }
    
    func oauthExchange(code: String) async throws -> JWTResponse {
        return try await post("oauth/exchange", body: [
            "code": code
        ])
    }

    // MARK: - SSO
    
    struct SSOResponse: JSONResponse {
        var url: String
    }
    
    func ssoStart(emailOrTenantName: String, redirectURL: String?) async throws -> OAuthResponse {
        return try await post("saml/authorize", params: [
            "tenant": emailOrTenantName,
            "redirectURL": redirectURL,
        ])
    }
    
    func ssoExchange(code: String) async throws -> JWTResponse {
        return try await post("saml/exchange", body: [
            "code": code
        ])
    }
    
    // MARK: - Access Key
    
    struct AccessKeyExchangeResponse: JSONResponse {
        var sessionJwt: String
    }
    
    func accessKeyExchange(_ accessKey: String) async throws -> AccessKeyExchangeResponse {
        return try await post("accesskey/exchange", headers: authorization(with: accessKey))
    }
    
    // MARK: - Others
    
    func me(refreshJwt: String) async throws -> UserResponse {
        return try await get("me", headers: authorization(with: refreshJwt))
    }
    
    func refresh(refreshJwt: String) async throws -> JWTResponse {
        return try await post("refresh", headers: authorization(with: refreshJwt))
    }
    
    func logout(refreshJwt: String) async throws {
        try await post("logout", headers: authorization(with: refreshJwt))
    }
    
    // MARK: - Shared
    
    static let refreshCookieName = "DSR"
    
    struct JWTResponse: JSONResponse {
        var sessionJwt: String
        var refreshJwt: String?
        var user: UserResponse?
        var firstSeen: Bool
        
        mutating func setValues(from response: HTTPURLResponse) {
            guard let url = response.url, let fields = response.allHeaderFields as? [String: String] else { return }
            let cookies = HTTPCookie.cookies(withResponseHeaderFields: fields, for: url)
            for cookie in cookies where cookie.name == refreshCookieName {
                refreshJwt = cookie.value
            }
        }
    }
    
    struct UserResponse: JSONResponse {
        var userId: String
        var loginIds: [String]
        var name: String?
        var picture: String?
        var email: String?
        var verifiedEmail: Bool = false
        var phone: String?
        var verifiedPhone: Bool = false
        var createdTime: Int
    }
    
    struct MaskedAddress: JSONResponse {
        var maskedEmail: String?
        var maskedPhone: String?
    }
    
    // MARK: - Internal
    
    override var basePath: String {
        return "v1/auth"
    }
    
    override var defaultHeaders: [String: String] {
        return [
            "Authorization": "Bearer \(config.projectId)",
            "x-descope-sdk-name": "swift",
            "x-descope-sdk-version": Descope.version,
        ]
    }
    
    override func errorForResponseData(_ data: Data) -> Error? {
        return DescopeError(errorResponse: data)
    }
    
    private func authorization(with value: String) -> [String: String] {
        return ["Authorization": "Bearer \(config.projectId):\(value)"]
    }
}

private extension SignUpDetails {
    var dictValue: [String: Any?] {
        return [
            "name": name,
            "phone": phone,
            "email": email,
        ]
    }
}

private extension DeliveryMethod {
    func ensurePhoneMethod() throws {
        if self != .sms && self != .whatsapp {
            throw DescopeError.invalidArguments.with(message: "Update phone can be done using SMS or WhatsApp only")
        }
    }
}