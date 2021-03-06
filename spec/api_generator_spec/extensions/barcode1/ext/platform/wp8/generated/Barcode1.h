#pragma once

#include "common/RhoStd.h"
#include "api_generator/MethodResult.h"
#include "api_generator/BaseClasses.h"

///////////////////////////////////////////////////////////
struct IBarcode1
{
    virtual ~IBarcode1(){}
    virtual void getProps(CMethodResult& oResult) = 0;
    virtual void getPropsWithString(const rho::StringW& strName, CMethodResult& oResult) = 0;
    virtual void getPropsWithArray(const rho::Vector<rho::StringW>& arNames, CMethodResult& oResult) = 0;
};

struct IBarcode1Singleton
{
    virtual ~IBarcode1Singleton(){}

    virtual void enumerate(CMethodResult& oResult) = 0;

    virtual rho::StringW getDefaultID() = 0;
    virtual rho::StringW getInitialDefaultID() = 0;
    virtual void setDefaultID(const rho::StringW& strID) = 0;

    virtual void addCommandToQueue(rho::common::IRhoRunnable* pFunctor) = 0;
    virtual void callCommandInThread(rho::common::IRhoRunnable* pFunctor) = 0;
};

struct IBarcode1Factory
{
    virtual ~IBarcode1Factory(){}

    virtual IBarcode1Singleton* getModuleSingleton() = 0;
    virtual IBarcode1* getModuleByID(const rho::StringW& strID) = 0;
};

class CBarcode1FactoryBase : public CModuleFactoryBase<IBarcode1, IBarcode1Singleton, IBarcode1Factory>
{
protected:
    static rho::common::CAutoPtr<CBarcode1FactoryBase> m_pInstance;

public:

    static void setInstance(CBarcode1FactoryBase* pInstance){ m_pInstance = pInstance; }
    static CBarcode1FactoryBase* getInstance(){ return m_pInstance; }

    static IBarcode1Singleton* getBarcode1SingletonS(){ return getInstance()->getModuleSingleton(); }
};

void Init_Barcode1_API();
