import React from 'react';
import { DatePicker } from 'antd';
import dayjs, { Dayjs } from 'dayjs';

const { RangePicker } = DatePicker;

interface DateRangeSelectorProps {
  onChange: (dates: [string, string] | null) => void;
}

const DateRangeSelector: React.FC<DateRangeSelectorProps> = ({ onChange }) => {
  const presets = [
    {
      label: '今日',
      value: [dayjs().startOf('day'), dayjs()] as [Dayjs, Dayjs],
    },
    {
      label: '昨日',
      value: [
        dayjs().subtract(1, 'day').startOf('day'),
        dayjs().subtract(1, 'day').endOf('day'),
      ] as [Dayjs, Dayjs],
    },
    {
      label: '近7天',
      value: [dayjs().subtract(7, 'day'), dayjs()] as [Dayjs, Dayjs],
    },
    {
      label: '近30天',
      value: [dayjs().subtract(30, 'day'), dayjs()] as [Dayjs, Dayjs],
    },
    {
      label: '本月',
      value: [dayjs().startOf('month'), dayjs()] as [Dayjs, Dayjs],
    },
    {
      label: '上月',
      value: [
        dayjs().subtract(1, 'month').startOf('month'),
        dayjs().subtract(1, 'month').endOf('month'),
      ] as [Dayjs, Dayjs],
    },
  ];

  const handleChange = (dates: [Dayjs | null, Dayjs | null] | null) => {
    if (dates && dates[0] && dates[1]) {
      onChange([
        dates[0].format('YYYY-MM-DD HH:mm:ss'),
        dates[1].format('YYYY-MM-DD HH:mm:ss'),
      ]);
    } else {
      onChange(null);
    }
  };

  return (
    <RangePicker
      presets={presets}
      showTime
      format="YYYY-MM-DD HH:mm:ss"
      onChange={handleChange}
    />
  );
};

export default DateRangeSelector;
