var addressbook_pb = require("./addressbook_pb")
var fs = require("fs")

function pbFileToJsonFile() {
    var content = fs.readFileSync("address")
    var addressbook = addressbook_pb.AddressBook.deserializeBinary(content)

    fs.writeFileSync("address.json", JSON.stringify(addressbook.toObject()))
}

function makeAddressbook()
{
    var addressbook = new addressbook_pb.AddressBook()
    var p1 = new addressbook_pb.Person()
    addressbook.addPeople(p1)

    var p2 = new addressbook_pb.Person()
    addressbook.addPeople(p2)

    var p3 = new addressbook_pb.Person()
    addressbook.addPeople(p3)

    p3.setId(3)
    p3.setName("P3")
    p3.setEmail("P3@World.com")

    var p3Phone = new addressbook_pb.Person.PhoneNumber(["P3_12345", addressbook_pb.Person.PhoneType.WORK])
    p3.addPhones(p3Phone)

    addressbook.addPeople(new addressbook_pb.Person(["P4", 4, "P4@World.com", [ ["P4_num_1", addressbook_pb.Person.PhoneType.HOME], ["P4_num_2", addressbook_pb.Person.PhoneType.MOBILE], ["P4_num_3", addressbook_pb.Person.PhoneType.WORK] ]]))
    console.log(JSON.stringify(addressbook.toObject()))

    // create many data
    var max = 99
    for (var i = 5; i < max; i++)
    {
        addressbook.addPeople(new addressbook_pb.Person([
            "P" + i, i, "P" + i + "@World.com",
            [
                ["P" + i + "_num_0", addressbook_pb.Person.PhoneType.MOBILE],
                ["P" + i + "_num_1", addressbook_pb.Person.PhoneType.HOME],
                ["P" + i + "_num_2", addressbook_pb.Person.PhoneType.WORK]
            ]
        ]))
    }

    // console.log(JSON.stringify(addressbook.toObject()))

    // save binary
    fs.writeFileSync("my_address_" + max + ".dat", addressbook.serializeBinary())

    // save json text
    fs.writeFileSync("my_address_" + max + ".json", JSON.stringify(addressbook.toObject()))

    return
}

function readAddressbook()
{
    // load binary file
    var addressbook = addressbook_pb.AddressBook.deserializeBinary(fs.readFileSync("my_address_99.dat"))
    console.log(addressbook.getPeopleList().length)

    var index = Math.floor(Math.random() * addressbook.getPeopleList().length)
    var person = addressbook.getPeopleList()[index]

    console.log(person.getId(), person.getName(), person.getPhonesList())
    console.log(JSON.stringify(person.toObject()))

    return
}

function main()
{
    // makeAddressbook()
    readAddressbook()
}

main()