#ifndef FireStPropertyObject_h_
#define FireStPropertyObject_h_

#include <FireDefinition.h>
#include <FireProperty.h>
#include <string>
#include <vector>

using namespace std;

NS_FIRE_BEGIN

class PropertyObject
{
public:
    static StProperty& get(const string& key, StProperty& prop, int defalutType = 0)
    {
        if (prop.name.compare(key) == 0) 
		{
            return prop;
        } 
		else 
		{
            if (prop.children.size()) 
			{
                vector<StProperty*> array;

                for (auto it = prop.children.begin(); it != prop.children.end(); it++) {
                    auto& property = *it;
                    array.push_back(&property);
                }

                for (auto ite = array.begin(); ite != array.end(); ite++) {
                    auto& property = *(*ite);
                    if (property.name.compare(key) == 0) {
                        return property;
                    } else {
                        for (auto it_1 = property.children.begin(); it_1 != property.children.end(); it_1++) {
                            auto& property_1 = *it_1;
                            array.push_back(&property_1);
                        }
                    }
                }
            }
        }

		StProperty p(defalutType);
		p.name = key;
		prop.children.push_back(p);

		auto it = prop.children.rbegin();
        return *it;
    }

public:
    PropertyObject() {
		root = StProperty(Type_Array);
	}
    ~PropertyObject() {}

    StProperty& get(const string& key, int defalutType = 0)
    {
        return PropertyObject::get(key, root, defalutType);
    }

public:
    StProperty root;
};

NS_FIRE_END__

#endif