import React, { useState, useEffect } from 'react';
import { RouterProvider } from 'react-router-dom';
import router from './router';
import { ConfigProvider, App as AntdApp } from 'antd';
import zhCN from 'antd/locale/zh_CN';
import enUS from 'antd/locale/en_US';
import { useTranslation } from 'react-i18next';
import './i18n';

const App: React.FC = () => {
  const { i18n } = useTranslation();
  const [locale, setLocale] = useState(zhCN);

  useEffect(() => {
    const currentLang = i18n.language;
    setLocale(currentLang === 'en' ? enUS : zhCN);
  }, [i18n.language]);

  return (
    <ConfigProvider
      locale={locale}
      theme={{
        token: {
          colorPrimary: '#1890ff',
        },
      }}
    >
      <AntdApp>
        <RouterProvider router={router} />
      </AntdApp>
    </ConfigProvider>
  );
};

export default App;
