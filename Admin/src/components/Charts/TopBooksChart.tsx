import React, { useEffect, useRef } from 'react';
import * as echarts from 'echarts';

const TopBooksChart: React.FC = () => {
  const chartRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (chartRef.current) {
      const chart = echarts.init(chartRef.current);
      
      const option = {
        title: {
          text: '阅读量 Top 10'
        },
        tooltip: {
          trigger: 'axis',
          axisPointer: {
            type: 'shadow'
          }
        },
        grid: {
          left: '3%',
          right: '4%',
          bottom: '3%',
          containLabel: true
        },
        xAxis: {
          type: 'value',
          boundaryGap: [0, 0.01]
        },
        yAxis: {
          type: 'category',
          data: ['Book A', 'Book B', 'Book C', 'Book D', 'Book E', 'Book F', 'Book G', 'Book H', 'Book I', 'Book J']
        },
        series: [
          {
            name: '阅读量',
            type: 'bar',
            data: [18203, 23489, 29034, 104970, 131744, 630230, 19325, 23438, 31000, 121594],
            itemStyle: { color: '#722ed1' }
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

export default TopBooksChart;
