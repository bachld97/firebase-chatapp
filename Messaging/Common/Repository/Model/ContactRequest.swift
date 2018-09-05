class ContactRequest {
    let contact: Contact
    let relation: ContactRelation
    
    init(contact: Contact, relation: ContactRelation) {
        self.contact = contact
        self.relation = relation
    } 
}

enum ContactRelation {
    case stranger
    case requesting
    case requested
}
