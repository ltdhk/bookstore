import React from 'react';
import { Input } from 'antd';

const { TextArea } = Input;

interface RichTextEditorProps {
  value?: string;
  onChange?: (value: string) => void;
  placeholder?: string;
}

const RichTextEditor: React.FC<RichTextEditorProps> = ({ value, onChange, placeholder }) => {
  const handleChange = (e: React.ChangeEvent<HTMLTextAreaElement>) => {
    if (onChange) {
      onChange(e.target.value);
    }
  };

  return (
    <div>
      <TextArea
        value={value}
        onChange={handleChange}
        placeholder={placeholder}
        rows={15}
        style={{
          fontFamily: 'monospace',
          fontSize: '14px'
        }}
      />
      <div style={{ marginTop: 8, color: '#666', fontSize: '12px' }}>
        提示: 支持HTML标签，如 &lt;p&gt;段落&lt;/p&gt;, &lt;h1&gt;标题&lt;/h1&gt;, &lt;strong&gt;粗体&lt;/strong&gt; 等
      </div>
    </div>
  );
};

export default RichTextEditor;
