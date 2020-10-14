import Foundation
import UIKit

private let VersionConfigShareInstance = VersionConfig()

open class VersionConfig {
    public class var share: VersionConfig {
        return VersionConfigShareInstance
    }
    
    public var version = "1.0.0"//最新的version
    
    public func getVersion(_ currentVersion: String) {
        let param: [String: Any] = ["data": ["appType": "APPLE",
                                             "version": currentVersion]]
        BaseNet.default.BaseNetParamRequest("/app/newVersion", param, nil, true, endAction: {}) { (data) in
            if let dic = data as? [String: Any], let newFlag = dic["newFlag"] as? Int, newFlag == 1 {//有更新
                if let versions = dic["version"] as? String, let content = dic["content"] as? String {
                    VersionConfig.share.version = versions
                    var isForce = false
                    if let forceUpdate = dic["forceUpdate"] as? Int, forceUpdate == 1 {
                        isForce = true
                    }
                    let versionPopView = VersionUpdatePopView(frame: UIScreen.main.bounds)
                    versionPopView.show(versions, content, isForce)
                }
            }
        }
    }
}

class VersionUpdatePopView: UIView {
    private var bgBtn = UIButton()
    private var versionLabel = UILabel()
    private var contentTV = UITextView()
    private var skipBtn = UIButton()
    
    private var skipURL = "https://itunes.apple.com/cn/app/id1515227373?mt=8"//苹果商店跳转地址
    private var isForce = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        bgBtn.backgroundColor = UIColor(hexString: "000000", alpha: 0.2)
        bgBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        addSubview(bgBtn)
        bgBtn.snp.makeConstraints { (make) in
            make.left.right.top.bottom.equalToSuperview()
        }
        
        let bgView = UIView()
        bgView.backgroundColor = UIColor.clear
        addSubview(bgView)
        bgView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.right.equalToSuperview().inset(60)
            make.height.equalTo(300)
        }
        
        let bottomView = UIView()
        bottomView.layer.cornerRadius = 5
        bottomView.clipsToBounds = true
        bottomView.backgroundColor = UIColor.white
        bgView.addSubview(bottomView)
        bottomView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.left.right.bottom.equalToSuperview()
        }
        
        let topImageView = UIImageView()
        topImageView.image = UIImage(named: "versionupdate_topbg", VersionUpdatePopView.self)
        bgView.addSubview(topImageView)
        topImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        versionLabel.backgroundColor = UIColor(hexString: "F6AF0F")
        versionLabel.textColor = UIColor.white
        versionLabel.font = UIFont.systemFont(ofSize: 18)
        versionLabel.textAlignment = .center
        versionLabel.layer.cornerRadius = 12
        versionLabel.clipsToBounds = true
        bgView.addSubview(versionLabel)
        versionLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(topImageView.snp.bottom).offset(12)
            make.width.equalTo(70)
            make.height.equalTo(24)
        }
        
        skipBtn.setTitle("前往App Store更新", for: .normal)
        skipBtn.setTitleColor(UIColor(hexString: "333333"), for: .normal)
        skipBtn.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        skipBtn.addTarget(self, action: #selector(clickMethod(_:)), for: .touchUpInside)
        bgView.addSubview(skipBtn)
        skipBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
            make.centerX.equalToSuperview()
            make.width.equalTo(140)
            make.height.equalTo(30)
        }
        
        contentTV.textColor = UIColor(hexString: "454545")
        contentTV.font = UIFont.systemFont(ofSize: 14)
        contentTV.isEditable = false
        contentTV.isSelectable = false
        contentTV.bounces = false
        bgView.addSubview(contentTV)
        contentTV.snp.makeConstraints { (make) in
            make.top.equalTo(versionLabel.snp.bottom).offset(6)
            make.left.right.equalToSuperview().inset(3)
            make.bottom.equalTo(skipBtn.snp.top).offset(-6)
        }
    }
    
    @objc private func clickMethod(_ sender: UIButton) {
        switch sender {
        case skipBtn:
            if let skipUrl = URL(string: skipURL) {
                UIApplication.shared.openURL(skipUrl)
            }
        case bgBtn:
            if !isForce {
                hideView()
            }
        default:
            break
        }
    }
    
    public func show(_ version: String?, _ content: String?, _ force: Bool) {
        versionLabel.text = version
        contentTV.text = content
        isForce = force
        UIApplication.shared.keyWindow?.rootViewController?.view.addSubview(self)
    }
    
    public func hideView() {
        self.removeFromSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
