import React, { useEffect, useRef } from 'react';
import * as echarts from 'echarts';
import type { TopBook } from '../../api/dashboard';

interface TopBooksChartProps {
  data: TopBook[];
}

const TopBooksChart: React.FC<TopBooksChartProps> = ({ data }) => {
  const chartRef = useRef<HTMLDivElement>(null);
  const chartInstance = useRef<echarts.ECharts | null>(null);

  useEffect(() => {
    if (chartRef.current) {
      chartInstance.current = echarts.init(chartRef.current);
    }

    return () => {
      chartInstance.current?.dispose();
    };
  }, []);

  useEffect(() => {
    if (!chartInstance.current || !data || data.length === 0) return;

    const bookTitles = data.map(book => book.title).reverse();
    const views = data.map(book => book.views).reverse();

    const option = {
      tooltip: {
        trigger: 'axis',
        axisPointer: {
          type: 'shadow',
        },
        backgroundColor: 'rgba(255, 255, 255, 0.95)',
        borderColor: '#e8e8e8',
        borderWidth: 1,
        textStyle: {
          color: '#262626',
        },
        formatter: (params: any) => {
          const param = params[0];
          return `<div>
            <div style="font-weight: 600; margin-bottom: 4px;">${param.name}</div>
            <div style="display: flex; align-items: center; gap: 8px;">
              <span style="display: inline-block; width: 10px; height: 10px; border-radius: 50%; background: ${param.color};"></span>
              <span style="flex: 1;">浏览量:</span>
              <span style="font-weight: 600;">${param.value.toLocaleString()}</span>
            </div>
          </div>`;
        },
      },
      grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        top: 20,
        containLabel: true,
      },
      xAxis: {
        type: 'value',
        boundaryGap: [0, 0.01],
        axisLine: {
          lineStyle: {
            color: '#e8e8e8',
          },
        },
        axisLabel: {
          color: '#8c8c8c',
          formatter: (value: number) => value.toLocaleString(),
        },
        splitLine: {
          lineStyle: {
            color: '#f0f0f0',
            type: 'dashed',
          },
        },
      },
      yAxis: {
        type: 'category',
        data: bookTitles,
        axisLine: {
          lineStyle: {
            color: '#e8e8e8',
          },
        },
        axisLabel: {
          color: '#595959',
          fontSize: 13,
        },
      },
      series: [
        {
          name: '浏览量',
          type: 'bar',
          data: views,
          itemStyle: {
            color: new echarts.graphic.LinearGradient(0, 0, 1, 0, [
              { offset: 0, color: '#722ed1' },
              { offset: 1, color: '#b37feb' },
            ]),
            borderRadius: [0, 4, 4, 0],
          },
          label: {
            show: true,
            position: 'right',
            formatter: (params: any) => params.value.toLocaleString(),
            color: '#595959',
            fontSize: 12,
          },
          barMaxWidth: 30,
        },
      ],
    };

    chartInstance.current.setOption(option);

    const handleResize = () => {
      chartInstance.current?.resize();
    };

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, [data]);

  return <div ref={chartRef} style={{ width: '100%', height: '400px' }} />;
};

export default TopBooksChart;
