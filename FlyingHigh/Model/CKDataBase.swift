import CloudKit
import Nuvem


//Tipos do Database do cloudkit
extension CKDatabase{
    //Publico se acessa apenas os challenges
    static let `public` = CKContainer(
        identifier: "iCloud.com.FelipePradodeLima.FlyingHigh"
    )
    .publicCloudDatabase
    
    //Usado para acessar o álbum
    static let `private` = CKContainer(
        identifier: "iCloud.com.FelipePradodeLima.FlyingHigh"
    )
    .privateCloudDatabase
    
    static let `shared` = CKContainer(
        identifier: "iCloud.com.FelipePradodeLima.FlyingHigh"
    )
    .sharedCloudDatabase
}
