
#ifndef FireJson_h
#define FireJson_h

#include "rapidjson/document.h"
#include "rapidjson/stringbuffer.h"
#include "rapidjson/writer.h"

#include <FireDefinition.h>
#include <FireProperty.h>
#include <FireStShaderPanel.h>
#include <FireUtility.h>

#include <string>

using namespace std;

NS_FIRE_BEGIN

void toWriter(const StProperty& prop, rapidjson::Writer<rapidjson::StringBuffer>& writer)
{
    writer.StartObject();
    {
        switch (prop.type)
        {
            case Type_Int:
            {
                writer.Key("Type"); writer.String(TypeNames[prop.type]);
                writer.Key("Name"); writer.String(prop.name.c_str());
                writer.Key("Value"); writer.String(toString(prop.iVal).c_str());
                writer.Key("Min"); writer.String(toString(prop.iMin).c_str());
                writer.Key("Max"); writer.String(toString(prop.iMax).c_str());
                break;
            }
            case Type_Float:
            {
                writer.Key("Type"); writer.String(TypeNames[prop.type]);
                writer.Key("Name"); writer.String(prop.name.c_str());
                writer.Key("Value"); writer.String(toString(prop.fVal).c_str());
                writer.Key("Min"); writer.String(toString(prop.fMin).c_str());
                writer.Key("Max"); writer.String(toString(prop.fMax).c_str());
                break;
            }
            case Type_Color:
            {
                writer.Key("Type"); writer.String(TypeNames[prop.type]);
                writer.Key("Name"); writer.String(prop.name.c_str());
                writer.Key("Value"); writer.StartObject();
                {
                    writer.Key("r"); writer.String(toString(prop.cfVal.r).c_str());
                    writer.Key("g"); writer.String(toString(prop.cfVal.g).c_str());
                    writer.Key("b"); writer.String(toString(prop.cfVal.b).c_str());
                    writer.Key("a"); writer.String(toString(prop.cfVal.a).c_str());
                }
                writer.EndObject();
                break;
            }
            case Type_Bool:
            {
                writer.Key("Type"); writer.String(TypeNames[prop.type]);
                writer.Key("Name"); writer.String(prop.name.c_str());
                writer.Key("Value"); writer.String(toString(prop.iVal).c_str());
                break;
            }
            default:
                break;
        }
    }
    writer.EndObject();
}

void toStProperty(const rapidjson::Value& object, StProperty& prop)
{
    // Type
    const char* Type = "Type";
    int type = 0;
    
    if (object.HasMember(Type) && object[Type].IsString())
    {
        type = getTypeByName(object[Type].GetString());
    }
    
    prop.init(type);
    
    // Name
    const char* Name = "Name";
    if (object.HasMember(Name) && object[Name].IsString())
    {
        prop.name = object[Name].GetString();
    }
    
    // Value
    switch (prop.type)
    {
        case Type_Int:
        {
            const char* Value = "Value";
            if (object.HasMember(Value) && object[Value].IsString()) {
                prop.iVal = parseString<int>(object[Value].GetString());
            }
            
            const char* Min = "Min";
            if (object.HasMember(Min) && object[Min].IsString()) {
                prop.iMin = parseString<int>(object[Min].GetString());
            }
            
            const char* Max = "Max";
            if (object.HasMember(Max) && object[Max].IsString()) {
                prop.iMax = parseString<int>(object[Max].GetString());
            }
            
            break;
        }
        case Type_Float:
        {
            const char* Value = "Value";
            if (object.HasMember(Value) && object[Value].IsString()) {
                prop.fVal = parseString<float>(object[Value].GetString());
            }
            
            const char* Min = "Min";
            if (object.HasMember(Min) && object[Min].IsString()) {
                prop.fMin = parseString<float>(object[Min].GetString());
            }
            
            const char* Max = "Max";
            if (object.HasMember(Max) && object[Max].IsString()) {
                prop.fMax = parseString<float>(object[Max].GetString());
            }
            break;
        }
        case Type_Color:
        {
            const char* Value = "Value";
            if (object.HasMember(Value) && object[Value].IsObject())
            {
                auto& vObject = object[Value];
                
                const char* r = "r";
                if (vObject.HasMember(r) && vObject[r].IsString())
                {
                    prop.cfVal.r = parseString<float>(vObject[r].GetString());
                }
                
                const char* g = "g";
                if (vObject.HasMember(g) && vObject[g].IsString())
                {
                    prop.cfVal.g = parseString<float>(vObject[g].GetString());
                }
                
                const char* b = "b";
                if (vObject.HasMember(b) && vObject[b].IsString())
                {
                    prop.cfVal.b = parseString<float>(vObject[b].GetString());
                }
                
                const char* a = "a";
                if (vObject.HasMember(a) && vObject[a].IsString())
                {
                    prop.cfVal.a = parseString<float>(vObject[a].GetString());
                }
            }
            
            break;
        }
        case Type_Bool:
        {
            const char* Value = "Value";
            if (object.HasMember(Value) && object[Value].IsString()) {
                prop.iVal = parseString<int>(object[Value].GetString());
            }
            
            break;
        }
        default:
            break;
    }
}

string toJSON(const struct StShaderPanel& stShaderPanel)
{
    string data = "";
    rapidjson::StringBuffer strBuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strBuf);
    
    writer.StartObject();
    writer.Key("PanelName");   writer.String(stShaderPanel.name.c_str());
    writer.Key("Description"); writer.String(stShaderPanel.name.c_str());
    writer.Key("IsShow");      writer.String(toString(stShaderPanel.isShow).c_str());
    writer.Key("VS");          writer.String(stShaderPanel.vertexShaderPath.c_str());
    writer.Key("FS");          writer.String(stShaderPanel.fragmentShaderPath.c_str());
    writer.Key("Properties");  writer.StartArray();
    {
        const auto& propertyArray = stShaderPanel.propertyArray;
        for (auto it = propertyArray.begin(); it != propertyArray.end(); it++)
        {
            const auto& prop = *it;
            toWriter(prop, writer);
        }
    }
    writer.EndArray();
    
    writer.EndObject();
    data = strBuf.GetString();
    return data;
}

void parseJSON(const string& jsonStr, struct StShaderPanel& stShaderPanel)
{
    rapidjson::Document doc;
    if (!doc.Parse(jsonStr.c_str()).HasParseError())
    {
        //PanelName
        {
            const char* PanelName = "PanelName";
            if (doc.HasMember(PanelName) && doc[PanelName].IsString())
            {
                stShaderPanel.name = doc[PanelName].GetString();
            }
        }
        
        //Description
        {
            const char* Description = "Description";
            if (doc.HasMember(Description) && doc[Description].IsString())
            {
                // stShaderPanel.name = doc[Description].GetString();
            }
        }
        
        //IsShow
        {
            const char* IsShow = "IsShow";
            if (doc.HasMember(IsShow) && doc[IsShow].IsString())
            {
                // stShaderPanel.name = doc[Description].GetString();
                stShaderPanel.isShow = parseString<bool>(doc[IsShow].GetString());
            }
        }
        
        // VS
        {
            const char* VS = "VS";
            if (doc.HasMember(VS) && doc[VS].IsString())
            {
                stShaderPanel.vertexShaderPath = doc[VS].GetString();
            }
        }
        
        // FS
        {
            const char* FS = "FS";
            if (doc.HasMember(FS) && doc[FS].IsString())
            {
                stShaderPanel.fragmentShaderPath = doc[FS].GetString();
            }
        }
        
        // Properties
        {
            const char* Properties = "Properties";
            if (doc.HasMember(Properties) && doc[Properties].IsArray())
            {
                const rapidjson::Value& array = doc[Properties];
                size_t len = array.Size();
                for (int i = 0; i < len; i++)
                {
                    auto& object = array[i];
                    if (object.IsObject())
                    {
                        struct StProperty prop;
                        toStProperty(object, prop);
                        stShaderPanel.propertyArray.push_back(prop);
                    }
                }
            }
        }
    }
    else
    {
        cout << "parse StShaderPanel json error" << endl;
    }
}

string toJSON(const struct StConfig& config)
{
    string data;
    rapidjson::StringBuffer strBuf;
    rapidjson::Writer<rapidjson::StringBuffer> writer(strBuf);
    writer.StartObject();
    {
        writer.Key("Width"); writer.String(toString(config.width).c_str());
        writer.Key("Height"); writer.String(toString(config.height).c_str());
    }
    writer.EndObject();
    data = strBuf.GetString();
    return data;
}

void parseJSON(const string& jsonStr, struct StConfig& config)
{
    rapidjson::Document doc;
    if (!doc.Parse(jsonStr.c_str()).HasParseError())
    {
        const char* Width = "Width";
        if (doc.HasMember(Width) && doc[Width].IsString()) {
            config.width = parseString<float>(doc[Width].GetString());
        }
        
        const char* Height = "Height";
        if (doc.HasMember(Height) && doc[Height].IsString()) {
            config.height = parseString<float>(doc[Height].GetString());
        }
    }
    else
    {
        cout << "parse StConfig json error" << endl;
    }
}

NS_FIRE_END__

#endif
