import React, { useEffect, useRef } from 'react';
import * as echarts from 'echarts';

const UserMapChart: React.FC = () => {
  const chartRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (chartRef.current) {
      const chart = echarts.init(chartRef.current);
      
      // Mock map data (using scatter/effectScatter on a geo coordinate system usually requires map JSON, 
      // for simplicity we'll use a pie chart to represent user distribution by region)
      const option = {
        title: {
          text: '用户分布',
          left: 'center'
        },
        tooltip: {
          trigger: 'item'
        },
        legend: {
          orient: 'vertical',
          left: 'left'
        },
        series: [
          {
            name: 'Access From',
            type: 'pie',
            radius: '50%',
            data: [
              { value: 1048, name: 'China' },
              { value: 735, name: 'USA' },
              { value: 580, name: 'Europe' },
              { value: 484, name: 'Japan' },
              { value: 300, name: 'Others' }
            ],
            emphasis: {
              itemStyle: {
                shadowBlur: 10,
                shadowOffsetX: 0,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
              }
            }
          }
        ]
      };

      chart.setOption(option);

      const handleResize = () => {
        chart.resize();
      };

      window.addEventListener('resize', handleResize);

      return () => {
        window.removeEventListener('resize', handleResize);
        chart.dispose();
      };
    }
  }, []);

  return <div ref={chartRef} style={{ width: '100%', height: '300px' }} />;
};

export default UserMapChart;
