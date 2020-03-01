//
//  RealmFunctions.swift
//  MVVM-todo
//
//  Created by Илья Ершов on 30/01/2020.
//  Copyright © 2020 Ilia Ershov. All rights reserved.
//

import RealmSwift

class RealmFunctions {
    
    private init(){}
    static let shared = RealmFunctions()
    
    lazy var realm: Realm = {
        return try! Realm()
    }()
    
    var currentSchemaVersion: UInt64 = 5
    
    func configureMigration(){
        let config = Realm.Configuration(schemaVersion: currentSchemaVersion,
                                         migrationBlock: { (migration, oldSchemaVersion) in
                                            if oldSchemaVersion < 1 {
                                                self.migrateFrom0To1(with: migration)
                                            }
                                            if oldSchemaVersion < 2 {
                                                self.migrateFrom1To2(with: migration)
                                            }
                                            if oldSchemaVersion < 3 {
                                                self.migrateFrom2To3(with: migration)
                                            }
                                            if oldSchemaVersion < 4 {
                                                self.migrateFrom3To4(with: migration)
                                            }
                                            if oldSchemaVersion < 5 {
                                                self.migrateFrom4To5(with: migration)
                                            }
                                            
        })
        Realm.Configuration.defaultConfiguration = config
    }
    
    private func migrateFrom0To1(with migration: Migration) {}
    private func migrateFrom1To2(with migration: Migration) {}
    private func migrateFrom2To3(with migration: Migration) {
        migration.enumerateObjects(ofType: Task.className()) { oldObject, newObject in
            // combine name fields into a single field
            let createdAt = oldObject!["date"] as! Date
            newObject!["createdAt"] = createdAt
        }
    }
    private func migrateFrom3To4(with migration: Migration) {}
    private func migrateFrom4To5(with migration: Migration) {}
    
    
}

