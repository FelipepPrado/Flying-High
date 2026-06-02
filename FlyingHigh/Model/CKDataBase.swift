import CloudKit
import Nuvem

extension CKDatabase{
    static let `default` = CKContainer(
        identifier: "iCloud.com.FelipePradodeLima.FlyingHigh"
    )
    .publicCloudDatabase
//    static let `public` = CKContainer(
//        identifier: "iCloud.com.FelipePradodeLima.FlyingHigh"
//    )
//    .publicCloudDatabase
}
