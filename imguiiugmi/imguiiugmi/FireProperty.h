#ifndef FireProperty_h
#define FireProperty_h

#include <FireDefinition.h>

#include <string>
#include <vector>

using namespace std;

NS_FIRE_BEGIN

struct StProperty {
    int id;
    int index;
    int type;
    string name;
    
    union {
        int iVal;
        float fVal;
    };
    
    union {
        int iMin;
        float fMin;
    };
    
    union {
        int iMax;
        float fMax;
    };
    
    union {
        Vec2 v2Val;
        Vec3 v3Val;
        
        Color cfVal;
        IColor cVal;
    };
    
    string sVal;
    PropertyArray children;
    
    //////////////////////////////////
    StProperty() {
        clear();
    }
    StProperty(int t) {
        init(t);
    }
    StProperty(const StProperty& prop) {
        *this = prop;
    }
    StProperty(StProperty&& prop) {
        *this = prop;
    }
    ~StProperty() {}
    
    void clear() {
        id = 0;
        index = 0;
        type = 0;
        name = "";
        iVal = iMin = iMax = 0;
        fVal = fMin = fMax = 0;
        memset(&v2Val, 0, sizeof(v2Val));
        memset(&v3Val, 0, sizeof(v3Val));
        memset(&cfVal, 0, sizeof(cfVal));
        memset(&cVal, 0, sizeof(cVal));
        sVal = "";
        children.clear();
    }
    void init() {
        sVal = "";
        name = "";
//        if (type == Type_Int) { iVal = 0; iMin = INT_MIN / 2; iMax = INT_MAX / 2; }
//        if (type == Type_Float) { fVal = 0; fMin = Float_Min; fMax = Float_Max; }
        if (type == Type_Int)         { iVal = 0; iMin = Int_Min_Normal; iMax = Int_Max_Normal; }
        else if (type == Type_Float)  { fVal = 0; fMin = Float_Min_Normal; fMax = Float_Max_Normal; }
        else if (type == Type_Vec2)   { v2Val = { 0, 0 }; }
        else if (type == Type_Vec3)   { v3Val = { 0, 0, 0 }; }
        else if (type == Type_Color)  { cfVal = { 0, 0, 0, 1.0 }; }
        else if (type == Type_IColor) { cVal = { 0, 0, 0, 255 }; }
        else if (type == Type_Bool)   { iVal = 0; }
    }
    void init(int t) {
        clear();
        type = t;
        init();
    }
    
    StProperty& operator=(const StProperty& prop) {
        index = prop.index;
        type = prop.type;
        name = prop.name;
        if (type == Type_Int)         { iVal = prop.iVal; iMin = prop.iMin; iMax = prop.iMax; }
        else if (type == Type_Float)  { fVal = prop.fVal; fMin = prop.fMin; fMax = prop.fMax; }
        else if (type == Type_Vec2)   { v2Val = prop.v2Val; }
        else if (type == Type_Vec3)   { v3Val = prop.v3Val; }
        else if (type == Type_Color)  { cfVal = prop.cfVal; }
        else if (type == Type_IColor) { cVal = prop.cVal;   }
        else if (type == Type_String) { sVal = prop.sVal;   }
        else if (type == Type_Bool)   { iVal = prop.iVal;   }
        else if (type == Type_Array)  { children = prop.children; }
        
        return *this;
    }
    StProperty& operator=(StProperty&& prop) {
        *this = prop;
        return *this;
    }
    
};

NS_FIRE_END__

#endif /* FireProperty_h */
