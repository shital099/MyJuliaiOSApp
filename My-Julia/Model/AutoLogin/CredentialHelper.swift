import Foundation
public class CredentialHelper {
    
    // MARK: Init
    private var host: String = ""
    private var protectionSpace: URLProtectionSpace

    //MARK: Shared Instance
    static let shared: CredentialHelper = CredentialHelper(host: APP_NAME)

    public init(host: String) {
        self.host = host
        protectionSpace = URLProtectionSpace(host: self.host, port: 0, protocol: "http", realm: nil, authenticationMethod: nil)
    }
    
    // MARK: Store credentials
    public func storeCredential(key: String, value: String) {
        let credential = URLCredential(user:key, password: value, persistence: .permanent)
        URLCredentialStorage.shared.set(credential, for: protectionSpace)
    }
    
    public func storeDefaultCredential(key: String, value: String) {
        let credential = URLCredential(user:key, password: value, persistence: .permanent)
        URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
    }
    
    // MARK: Retrieve credentials
    private var credentials: [String:AnyObject] {
        if let dict = URLCredentialStorage.shared.credentials(for: protectionSpace) {
            return dict as [String : AnyObject]
        }
        return [String:AnyObject]()
    }
    
    public var credentialCount: Int {
        return credentials.count
    }
    
    private func credentialForKey(key: String) -> URLCredential? {
        if let credential: URLCredential = credentials[key] as? URLCredential {
            return credential
        }
        return nil
    }
    
    private func valueForKey(key: String) -> String? {
        if let credential = credentialForKey(key: key) {
            return credential.password
        }
        return nil
    }
    
    // MARK: Edit credentials
    public func removeCredential(key: String) {
        if let credential: URLCredential = credentials[key] as? URLCredential {
            URLCredentialStorage.shared.remove(credential, for: protectionSpace)
        }
    }
    
    public func removeAllCredentials() {
        for key in credentials.keys {
            removeCredential(key: key)
        }
    }
    
    // MARK: Default credentials
    public var defaultCredential: URLCredential? {
        return URLCredentialStorage.shared.defaultCredential(for: protectionSpace)
    }
    
    private func setDefaultCredential(key: String) {
        if let value = self[key] {
            let credential = URLCredential(user:key, password: value, persistence: .permanent)
            URLCredentialStorage.shared.setDefaultCredential(credential, for: protectionSpace)
        } else {
            print("Credential not found. Default credential is unchanged")
        }
    }
    
    public var defaultKey: NSString? {
        get {return defaultCredential?.user! as NSString?}
        set (newValue) {
            if let newValue = newValue {
                setDefaultCredential(key: newValue as String)
            } else {
                print("Nil key. Default credential is unchanged")
            }
        }
    }
    
    // I strongly considered letting assignment to nil remove the entire credential here
    public var defaultValue: NSString? {
        get {return defaultCredential?.password as NSString?}
        set (newValue) {
            if let newValue = newValue {
                if let defaultKey = defaultKey {
                    storeCredential(key: defaultKey as String, value: newValue as String)
                }
            } else {
                print("Nil value. Default credential is unchanged")
            }
        }
    }
    
    // MARK: Dictionary access -- preferred entry point for assignment and retrieval
    public subscript (key: String) -> String? {
        get {return valueForKey(key: key)}
        set(newValue) {
            if let newValue = newValue {
                storeCredential(key: key, value: newValue)
            } else {
                removeCredential(key: key)
            }
        }
    }
}
